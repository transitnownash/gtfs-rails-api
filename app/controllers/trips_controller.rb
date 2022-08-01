class TripsController < ApplicationController
  before_action :set_trip, only: [:show, :show_stop_times, :show_shape, :show_block]

  # GET /trips
  def index
    date = params[:date] unless params[:date].nil?
    render json: paginate_results(Trip.active(date).includes(:shape, :stop_times, { stop_times: :stop }))
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

  # GET /trips/:id/block
  def show_block
    render json: @trip.block
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_trip
    @trip = Trip.includes(:shape, :stop_times, { stop_times: :stop }).find_by_trip_gid(params[:trip_gid])
    raise ActionController::RoutingError.new('Not Found') if @trip.nil?
  end
end
