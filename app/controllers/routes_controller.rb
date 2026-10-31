# frozen_string_literal: true

##
# Routes Controller
class RoutesController < ApplicationController
  before_action :set_route, only: %i[show show_trips show_shapes show_stops]

  # GET /routes
  def index
    date = params[:date] unless params[:date].nil?
    render json: paginate_results(Route.active(date))
  end

  # GET /routes/1
  def show
    render json: @route
  end

  # GET /routes/1/trips
  def show_trips
    date = params[:date] unless params[:date].nil?
    cache_key = "routes/#{@route.route_gid}/trips/#{date || 'all'}-page#{params[:page] || 1}-per#{params[:per_page] || 100}"
    result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      paginate_results(@route.trips.active(date).includes(:shape, :stop_times, { stop_times: :stop })).to_json
    end
    render json: result
  end

  # GET /routes/1/shapes
  def show_shapes
    date = params[:date] unless params[:date].nil?
    render json: paginate_results(Shape.includes(:trips).where(trips: { route_gid: params[:route_gid], id: Trip.active(date) }))
  end

  # GET /routes/1/stops
  def show_stops
    date = params[:date] unless params[:date].nil?
    render json: paginate_results(
      Stop.joins(stop_times: [:trip]).where(trip: { route_gid: params[:route_gid], id: Trip.active(date) }).distinct
    )
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_route
    @route = Route.find_by(route_gid: params[:route_gid])
    @route = Route.find_by(route_short_name: params[:route_gid]) if @route.nil?
    raise ActionController::RoutingError, 'Not Found' if @route.nil?
  end
end
