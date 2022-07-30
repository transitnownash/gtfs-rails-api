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
    render json: paginate_results(StopTime.where(stop_gid: @stop.stop_gid))
  end

  # Get /stops/1/trips
  def show_trips
    render json: paginate_results(
      Trip.active.includes(:shape, :stop_times, { stop_times: :stop }).where(stop_times: { stop_gid: @stop.stop_gid })
    )
  end

  # Get /stops/1/routes
  def show_routes
    child_stop_ids = @stop.child_stops.map(&:stop_gid)
    routes = Route.joins(trips: [:stop_times])
                  .where(stop_times: { stop_gid: @stop.stop_gid })
                  .or(
                    Route.joins(trips: [:stop_times]).where(stop_times: { stop_gid: child_stop_ids })
                  ).distinct
    render json: paginate_results(routes)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stop
    @stop = Stop.find_by_stop_gid(params[:stop_gid])
    @stop = Stop.find_by_stop_code(params[:stop_gid]) if @stop.nil?
    raise ActionController::RoutingError.new('Not Found') if @stop.nil?
  end
end
