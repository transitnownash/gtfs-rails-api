# frozen_string_literal: true

class StopTimesController < ApplicationController
  before_action :set_stop_time, only: [:show]

  # GET /stop_times
  def index
    render json: paginate_results(StopTime.all)
  end

  # GET /stop_times/1
  def show
    render json: @stop_times
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stop_time
    @stop_times = StopTime.where(stop_gid: params[:stop_gid])
    raise ActionController::RoutingError, 'Not Found' if @stop_times.empty?
  end
end
