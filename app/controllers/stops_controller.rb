class StopsController < ApplicationController
  before_action :set_stop, only: [:show, :show_stop_times, :show_trips, :show_routes]

  # GET /stops
  def index
    render json: paginate_results(Stop.all)
  end

  # GET /stops/1
  def show
    render json: @stop, methods: [:child_stops, :parent_station]
  end

  # Get /stops/1/stop_times
  def show_stop_times
    stop_gids = [@stop.stop_gid]
    stop_gids += @stop.child_stops.map(&:stop_gid)
    render json: paginate_results(StopTime.where(stop_gid: stop_gids))
  end

  # Get /stops/1/trips
  def show_trips
    stop_gids = [@stop.stop_gid]
    stop_gids += @stop.child_stops.map(&:stop_gid)
    render json: paginate_results(
      Trip.active.includes(:shape, :stop_times, { stop_times: :stop }).where(stop_times: { stop_gid: stop_gids })
    )
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
    @stop = Stop.find_by_stop_gid(params[:stop_gid])
    @stop = Stop.find_by_stop_code(params[:stop_gid]) if @stop.nil?
    raise ActionController::RoutingError.new('Not Found') if @stop.nil?
  end
end
