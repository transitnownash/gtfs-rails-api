class TripsController < ApplicationController
  before_action :set_trip, only: [:show, :show_stop_times, :show_shape]

  # GET /trips
  def index
    @trips = Trip.all

    render json: @trips
  end

  # GET /trips/:id
  def show
    render json: @trip
  end

  # GET /trips/:id/stop_times
  def show_stop_times
    render json: StopTime.where(trip_id: @trip.trip_id)
  end

  # GET /trips/:id/shape
  def show_shape
    render json: Shape.where(shape_id: @trip.shape_id)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_trip
    @trip = Trip.find(params[:id])
  end
end
