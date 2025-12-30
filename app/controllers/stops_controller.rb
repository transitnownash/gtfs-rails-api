# frozen_string_literal: true

require 'protobuf'
require 'google/transit/gtfs-realtime.pb'

class StopsController < ApplicationController
  before_action :set_stop, only: %i[show show_stop_times show_trips show_routes next]

  # GET /stops
  def index
    render json: paginate_results(Stop.all)
  end

  # GET /stops/near/36.165,-86.78406
  # GET /stops/near/36.165,-86.78406/100
  def nearby
    radius = params[:radius] || 100
    render json: paginate_results(Stop.within(radius,
                                              origin: [params[:latitude],
                                                       params[:longitude]]).by_distance(origin: [params[:latitude],
                                                                                                 params[:longitude]]))
  end

  # GET /stops/1
  def show
    cache_key = "stops/#{@stop.stop_gid}/details"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      @stop.as_json(methods: %i[child_stops parent_station])
    end
    render json: result
  end

  # GET /stops/1/next
  def next
    date_filter = params[:date].presence
    time_filter = normalized_time_param
    cache_key = "stops/#{@stop.stop_gid}/next/#{date_filter || 'today'}/t#{time_filter[0, 5].delete(':')}"

    result = Rails.cache.fetch(cache_key, expires_in: 30.seconds) do
      filtered = StopTime
                 .joins(:trip)
                 .merge(Trip.active(date_filter))
                 .where(stop_gid: stop_and_children_gids)
                 .includes(trip: %i[route shape])
                 .to_a
                 .select { |st| arrival_time_seconds(st.arrival_time) >= arrival_time_seconds(time_filter) }
                 .sort_by { |st| arrival_time_seconds(st.arrival_time) }
                 .first(4)

      realtime_updates = fetch_realtime_updates

      {
        stop: @stop.as_json(methods: %i[child_stops parent_station]),
        next_trip: filtered.first ? serialize_stop_time_with_trip(filtered.first, realtime_updates) : nil,
        upcoming_trips: filtered.drop(1).first(3).map { |stop_time| serialize_stop_time_with_trip(stop_time, realtime_updates) }
      }
    end

    render json: result
  end

  # Get /stops/1/stop_times
  def show_stop_times
    stop_gids = [@stop.stop_gid]
    stop_gids += @stop.child_stops.map(&:stop_gid)
    cache_key = "stops/#{@stop.stop_gid}/stop_times-page#{params[:page] || 1}-per#{params[:per_page] || 100}"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      paginate_results(StopTime.where(stop_gid: stop_gids))
    end
    render json: result
  end

  # Get /stops/1/trips
  def show_trips
    stop_gids = [@stop.stop_gid]
    stop_gids += @stop.child_stops.map(&:stop_gid)
    date = params[:date] unless params[:date].nil?
    cache_key = "stops/#{@stop.stop_gid}/trips/#{date || 'all'}-page#{params[:page] || 1}-per#{params[:per_page] || 100}"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      paginate_results(
        Trip.active(date)
            .includes(:shape, :stop_times, { stop_times: :stop })
            .where(stop_times: { stop_gid: stop_gids })
            .distinct
      )
    end
    render json: result
  end

  # Get /stops/1/routes
  def show_routes
    stop_gids = [@stop.stop_gid]
    stop_gids += @stop.child_stops.map(&:stop_gid)
    render json: paginate_results(Route.joins(trips: [:stop_times]).where(stop_times: { stop_gid: stop_gids }).distinct)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stop
    @stop = Stop.find_by(stop_gid: params[:stop_gid])
    @stop = Stop.find_by(stop_code: params[:stop_gid]) if @stop.nil?
    raise ActionController::RoutingError, 'Not Found' if @stop.nil?
  end

  def stop_and_children_gids
    [@stop.stop_gid] + @stop.child_stops.map(&:stop_gid)
  end

  def normalized_time_param
    raw_time = params[:time]
    return Time.zone.now.strftime('%H:%M:%S') if raw_time.blank?

    Time.zone.parse(raw_time).strftime('%H:%M:%S')
  rescue ArgumentError, TypeError
    Time.zone.now.strftime('%H:%M:%S')
  end

  def serialize_stop_time_with_trip(stop_time, realtime_updates = {})
    trip = stop_time.trip
    trip_payload = trip
                   .slice(:id, :trip_gid, :trip_headsign, :trip_short_name, :direction_id,
                          :block_gid, :shape_gid, :service_gid, :start_time, :end_time, :route_gid, :route_id,
                          :calendar_id)
    trip_payload['route'] = trip.route&.slice(:id, :route_gid, :route_short_name, :route_long_name, :route_desc,
                                              :route_type, :route_url, :route_color, :route_text_color)
    trip_payload['shape'] = trip.shape&.as_json(only: %i[id shape_gid], methods: :points)

    stop_time_payload = stop_time.slice(:arrival_time, :departure_time, :stop_sequence, :stop_headsign,
                                        :pickup_type, :drop_off_type, :shape_dist_traveled, :timepoint, :stop_gid)

    realtime_update = find_realtime_update_for_stop(trip.trip_gid, stop_time.stop_gid, realtime_updates)
    if realtime_update
      stop_time_payload['realtime'] = realtime_update
    end

    {
      stop_time: stop_time_payload,
      trip: trip_payload
    }
  end

  def arrival_time_seconds(value)
    return value.seconds_since_midnight.to_i if value.respond_to?(:seconds_since_midnight)

    parsed = if value.respond_to?(:to_time)
               value.to_time
             else
               Time.zone.parse(value.to_s)
             end
    parsed.seconds_since_midnight.to_i
  rescue ArgumentError, TypeError
    0
  end

  def fetch_realtime_updates
    return {} if Rails.env.test?
    return {} unless ENV.fetch('GTFS_REALTIME_TRIP_UPDATES_URL', nil)

    # Leverage the realtime_trip_updates endpoint via cache
    realtime_json = Rails.cache.fetch('/realtime/trip_updates.json', expires_in: 5.seconds) do
      begin
        uri = URI.parse(ENV.fetch('GTFS_REALTIME_TRIP_UPDATES_URL'))
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.read_timeout = 5
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        return [] unless response.is_a?(Net::HTTPSuccess)

        # Use RealtimeController's method to decode the protobuf
        realtime_controller = RealtimeController.new
        # Temporarily set up a minimal request context
        realtime_controller.instance_eval do
          @_request = ActionDispatch::TestRequest.create
          @_response = ActionDispatch::TestResponse.new
        end

        # Decode using the RealtimeController's trip_updates logic
        require 'protobuf'
        require 'google/transit/gtfs-realtime.pb'

        feed = Transit_realtime::FeedMessage.decode(response.body)
        entities = feed.entity.map { |entity| entity.to_hash }

        # Convert symbol keys to string keys for JSON serialization
        entities.map { |entity| convert_keys_to_strings(entity) }
      rescue StandardError => e
        Rails.logger.warn("Failed to fetch realtime trip updates: #{e.message}")
        []
      end
    end

    indexed = realtime_json.index_by { |entity| entity.dig('trip_update', 'trip', 'trip_id') }.tap do |h|
      h.default = {}
    end
    Rails.logger.debug("Indexed realtime updates with #{indexed.keys.length} trips")
    indexed
  rescue StandardError => e
    Rails.logger.warn("Error in fetch_realtime_updates: #{e.message}")
    {}
  end

  def convert_keys_to_strings(hash)
    return hash unless hash.is_a?(Hash)

    hash.transform_keys { |k| k.to_s }.transform_values do |v|
      case v
      when Hash
        convert_keys_to_strings(v)
      when Array
        v.map { |item| item.is_a?(Hash) ? convert_keys_to_strings(item) : item }
      else
        v
      end
    end
  end

  def find_realtime_update_for_stop(trip_gid, stop_gid, realtime_updates)
    # The realtime feed uses numeric trip_id, but we have trip_gid from the database
    # Try to find a realtime update using the trip_gid directly first
    trip_update = realtime_updates[trip_gid]

    # If not found and trip_gid looks numeric, try looking it up as a numeric ID
    unless trip_update
      # Try to find the trip in the database and get its numeric ID if available
      trip = Trip.find_by(trip_gid: trip_gid)
      if trip
        # Try using the database ID
        trip_update = realtime_updates[trip.id.to_s]
      end
    end

    unless trip_update
      Rails.logger.debug("Realtime update not found for trip_gid: #{trip_gid}")
      return nil
    end

    # Use string keys to access the data structure (converted by convert_keys_to_strings)
    stop_time_updates = trip_update.dig('trip_update', 'stop_time_update') || []
    stop_update = stop_time_updates.find { |stu| stu['stop_id'] == stop_gid }

    unless stop_update
      Rails.logger.debug("Stop update not found for stop_gid: #{stop_gid} in trip: #{trip_gid}")
      return nil
    end

    {
      arrival: stop_update.dig('arrival', 'time') ? Time.at(stop_update.dig('arrival', 'time')).in_time_zone('America/Chicago').strftime('%H:%M:%S') : nil,
      departure: stop_update.dig('departure', 'time') ? Time.at(stop_update.dig('departure', 'time')).in_time_zone('America/Chicago').strftime('%H:%M:%S') : nil,
      schedule_relationship: stop_update['schedule_relationship']
    }.compact
  end
end
