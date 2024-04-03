# frozen_string_literal: true

##
# Realtime Controller
class RetailLocationsController < ApplicationController
  before_action :set_retail_location, only: [:show]

  # GET /retail_locations
  def index
    render json: paginate_results(RetailLocation.all)
  end

  def show
    render json: @retail_location
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_retail_location
    @retail_location = RetailLocation.find_by(location_code: params[:location_code])
    raise ActionController::RoutingError, 'Not Found' if @retail_location.nil?
  end
end
