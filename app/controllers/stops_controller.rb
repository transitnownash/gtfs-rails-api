# frozen_string_literal: true

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
    current_time_seconds = arrival_time_seconds(time_filter)

    # Query today's service which includes both normal times (< 24:00:00) and
    # midnight-spanning times (>= 24:00:00, which represent times after midnight)
    # Note: We use unscope(:order) to prevent the default_scope from converting GTFS 24+ times
    all_trips = StopTime
                .unscope(:order)
                .joins(:trip)
                .merge(Trip.active(date_filter))
                .where(stop_gid: stop_and_children_gids)
                .includes(trip: :route)
                .to_a

    # Rank every stop_time by how many seconds from now it arrives, then take the soonest 4.
    filtered = all_trips
               .map { |st| [st, seconds_until_arrival(st.arrival_time, current_time_seconds)] }
               .select { |(_st, delta)| delta }
               .sort_by { |(_st, delta)| delta }
               .first(4)
               .map(&:first)

    realtime_updates = fetch_realtime_updates
    alerts = fetch_and_filter_alerts(@stop.stop_gid, filtered.first&.trip&.route_gid)

    vehicles_by_trip = fetch_vehicle_positions_by_trip
    vehicle_positions = filtered.filter_map { |stop_time| vehicles_by_trip[stop_time.trip.trip_gid] }

    result = {
      stop: @stop.as_json(methods: %i[child_stops parent_station]),
      next_trip: filtered.first ? serialize_stop_time_with_trip(filtered.first, realtime_updates) : nil,
      upcoming_trips: filtered.drop(1).first(3).map { |stop_time| serialize_stop_time_with_trip(stop_time, realtime_updates, include_shape: false) },
      alerts: alerts,
      vehicle_positions: vehicle_positions
    }

    render json: result
  end

  # Get /stops/1/stop_times
  def show_stop_times
    stop_gids = [@stop.stop_gid]
    stop_gids += @stop.child_stops.map(&:stop_gid)
    cache_key = "stops/#{@stop.stop_gid}/stop_times-page#{params[:page] || 1}-per#{params[:per_page] || 100}"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      paginate_results(StopTime.where(stop_gid: stop_gids).includes(:stop)).to_json
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
      ).to_json
    end
    render json: result
  end

  # Get /stops/1/routes
  def show_routes
    stop_gids = [@stop.stop_gid]
    stop_gids += @stop.child_stops.map(&:stop_gid)
    cache_key = "stops/#{@stop.stop_gid}/routes-page#{params[:page] || 1}-per#{params[:per_page] || 100}"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      paginate_results(Route.joins(trips: [:stop_times]).where(stop_times: { stop_gid: stop_gids }).distinct).to_json
    end
    render json: result
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

  # Seconds from current_time_seconds until this stop_time's arrival, or nil if it
  # isn't upcoming.
  #
  # GTFS times >= 24:00:00 (e.g. "25:15:00") represent a stop visited after midnight,
  # still attributed to today's service day. We normalize those to a real clock time
  # (25:15 -> 1:15) and measure forward from now, wrapping to the next occurrence if
  # that clock time has already passed today (e.g. now = 5 AM, arrival normalizes to
  # 12:48 AM -> ~20 hours away, not "already happened").
  #
  # Normal-format times (< 24:00:00) never wrap: once they've passed today they're
  # excluded rather than treated as tomorrow's occurrence.
  def seconds_until_arrival(arrival_time, current_time_seconds)
    arrival_seconds = arrival_time_seconds(arrival_time)

    if arrival_seconds >= 86400
      normalized = arrival_seconds - 86400
      return normalized >= current_time_seconds ? normalized - current_time_seconds : normalized + 86400 - current_time_seconds
    end

    return nil unless arrival_seconds > current_time_seconds

    arrival_seconds - current_time_seconds
  end

  def serialize_stop_time_with_trip(stop_time, realtime_updates = {}, include_shape: true)
    trip = stop_time.trip
    trip_payload = trip
                   .slice(:id, :trip_gid, :trip_headsign, :trip_short_name, :direction_id,
                          :block_gid, :shape_gid, :service_gid, :start_time, :end_time, :route_gid, :route_id,
                          :calendar_id)
    trip_payload['route'] = trip.route&.slice(:id, :route_gid, :route_short_name, :route_long_name, :route_desc,
                                              :route_type, :route_url, :route_color, :route_text_color)
    if include_shape && trip.shape
      shape_points = trip.shape.points
      trip_payload['shape'] = {
        id: trip.shape.id,
        shape_gid: trip.shape.shape_gid,
        # Simplify shape points to only lat/lon
        points: shape_points.map { |point| { lat: point['lat'], lon: point['lon'] } }
      }
    end

    stop_time_payload = stop_time.slice(:arrival_time, :departure_time, :stop_sequence, :stop_headsign,
                                        :pickup_type, :drop_off_type, :shape_dist_traveled, :timepoint, :stop_gid)

    # Force string values for GTFS times which can exceed 24:00:00
    stop_time_payload['arrival_time'] = stop_time.read_attribute_before_type_cast(:arrival_time)
    stop_time_payload['departure_time'] = stop_time.read_attribute_before_type_cast(:departure_time)

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

    # Handle GTFS time strings which can exceed 24:00:00 (e.g., "25:30:00" for 1:30 AM next day)
    if value.is_a?(String) && value.match?(/^\d{2}:\d{2}:\d{2}$/)
      parts = value.split(':')
      hours = parts[0].to_i
      minutes = parts[1].to_i
      seconds = parts[2].to_i
      return (hours * 3600) + (minutes * 60) + seconds
    end

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
    RealtimeFeeds.entities(:trip_updates)
                 .index_by { |entity| entity.dig(:trip_update, :trip, :trip_id) }
                 .tap { |indexed| indexed.default = {} }
  rescue StandardError => e
    Rails.logger.warn("Error in fetch_realtime_updates: #{e.message}")
    {}
  end

  def find_realtime_update_for_stop(trip_gid, stop_gid, realtime_updates)
    stop_time_updates = realtime_updates[trip_gid]&.dig(:trip_update, :stop_time_update) || []
    stop_update = stop_time_updates.find { |stu| stu[:stop_id] == stop_gid }
    return nil unless stop_update

    {
      arrival: stop_update.dig(:arrival, :time) ? Time.at(stop_update.dig(:arrival, :time)).in_time_zone('America/Chicago').strftime('%H:%M:%S') : nil,
      departure: stop_update.dig(:departure, :time) ? Time.at(stop_update.dig(:departure, :time)).in_time_zone('America/Chicago').strftime('%H:%M:%S') : nil,
      schedule_relationship: stop_update[:schedule_relationship]
    }.compact
  end

  def fetch_and_filter_alerts(stop_gid, route_gid)
    RealtimeFeeds.entities(:alerts).select do |entity|
      (entity.dig(:alert, :informed_entity) || []).any? do |informed|
        informed[:stop_id] == stop_gid || informed[:route_id] == route_gid
      end
    end.map do |entity|
      alert = entity[:alert].dup
      alert[:cause] = RealtimeFeeds::ALERT_CAUSES[alert[:cause]] if alert[:cause]
      alert[:effect] = RealtimeFeeds::ALERT_EFFECTS[alert[:effect]] if alert[:effect]
      alert
    end
  rescue StandardError => e
    Rails.logger.warn("Error in fetch_and_filter_alerts: #{e.message}")
    []
  end

  def fetch_vehicle_positions_by_trip
    RealtimeFeeds.entities(:vehicle_positions).each_with_object({}) do |entity, by_trip|
      by_trip[entity.dig(:vehicle, :trip, :trip_id)] ||= entity[:vehicle]
    end
  rescue StandardError => e
    Rails.logger.warn("Error in fetch_vehicle_positions_by_trip: #{e.message}")
    {}
  end
end
