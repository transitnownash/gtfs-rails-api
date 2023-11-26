# frozen_string_literal: true

##
# Stop Times Controller
class StopTimesController < ApplicationController
  before_action :set_stop_time, only: [:show]

  # GET /stop_times
  def index
    render json: paginate_results(StopTime.all)
  end

  # GET /stop_times/1
  def show
    render json: @stop_time
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stop_time
    @stop_time = StopTime.find(params[:id])
    raise ActionController::RoutingError, 'Not Found' if @stop_time.nil?
  end
end
