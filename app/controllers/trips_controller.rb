# frozen_string_literal: true

##
# Trips Controller
class TripsController < ApplicationController
  before_action :set_trip, only: %i[show show_stop_times show_shape show_block]

  # GET /trips
  def index
    date = params[:date] unless params[:date].nil?
    cache_key = "trips/index/#{date || 'all'}-page#{params[:page] || 1}-per#{params[:per_page] || 100}"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      paginate_results(Trip.active(date).includes(:shape, :stop_times, { stop_times: :stop }))
    end
    render json: result
  end

  # GET /trips/:id
  def show
    cache_key = "trips/#{@trip.trip_gid}/details"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      @trip.as_json
    end
    render json: result
  end

  # GET /trips/:id/stop_times
  def show_stop_times
    cache_key = "trips/#{@trip.trip_gid}/stop_times-page#{params[:page] || 1}-per#{params[:per_page] || 100}"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      paginate_results(@trip.stop_times)
    end
    render json: result
  end

  # GET /trips/:id/shape
  def show_shape
    cache_key = "trips/#{@trip.trip_gid}/shape"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      @trip.shape
    end
    render json: result
  end

  # GET /trips/:id/block
  def show_block
    cache_key = "trips/#{@trip.trip_gid}/block"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      @trip.block
    end
    render json: result
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_trip
    @trip = Trip.active.includes(:shape, :stop_times, { stop_times: :stop }).find_by(trip_gid: params[:trip_gid])
    raise ActionController::RoutingError, 'Not Found' if @trip.nil?
  end
end
