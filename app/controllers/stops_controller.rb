# frozen_string_literal: true

class StopsController < ApplicationController
  before_action :set_stop, only: %i[show show_stop_times show_trips show_routes]

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
    date = params[:date] unless params[:date].nil?
    cache_key = "stops/#{@stop.stop_gid}/trips/#{date || 'all'}-page#{params[:page] || 1}-per#{params[:per_page] || 100}"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      paginate_results(
        Trip.active(date).includes(:shape, :stop_times, { stop_times: :stop }).where(stop_times: { stop_gid: stop_gids })
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
end
