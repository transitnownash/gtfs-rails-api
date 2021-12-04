class TripsController < ApplicationController
  before_action :set_trip, only: [:show, :show_stop_times, :show_shape]

  # GET /trips
  def index
    render json: paginate_results(Trip.active)
  end

  # GET /trips/:id
  def show
    render json: @trip
  end

  # GET /trips/:id/stop_times
  def show_stop_times
    render json: paginate_results(@trip.stop_times)
  end

  # GET /trips/:id/shape
  def show_shape
    render json: @trip.shape
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_trip
    @trip = Trip.find_by_trip_gid(params[:trip_gid])
    raise ActionController::RoutingError.new('Not Found') if @trip.nil?
  end
end
