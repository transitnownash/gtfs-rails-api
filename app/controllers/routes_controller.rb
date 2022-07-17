class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :show_trips, :show_shapes, :show_stops]

  # GET /routes
  def index
    render json: paginate_results(Route.all)
  end

  # GET /routes/1
  def show
    render json: @route
  end

  # GET /routes/1/trips
  def show_trips
    render json: paginate_results(@route.trips.active.includes(:shape, :stop_times, { stop_times: :stop }))
  end

  # GET /routes/1/shapes
  def show_shapes
    render json: paginate_results(Shape.includes(:trips).where(trips: { route_gid: params[:route_gid] }))
  end

  # GET /routes/1/stops
  def show_stops
    render json: paginate_results(
      Stop.joins(stop_times: [:trip]).where(trip: { route_gid: params[:route_gid] }).distinct
    )
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_route
    @route = Route.find_by(route_gid: params[:route_gid])
    @route = Route.find_by(route_short_name: params[:route_gid]) if @route.nil?
    raise ActionController::RoutingError.new('Not Found') if @route.nil?
  end
end
