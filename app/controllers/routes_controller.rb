class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :show_trips]

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
    render json: paginate_results(@route.trips.active)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_route
    @route = Route.find_by_route_gid(params[:route_gid])
    raise 'NotFoundException' if @route.nil?
  end
end
