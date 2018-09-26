class StopsController < ApplicationController
  before_action :set_stop, only: [:show]

  # GET /stops
  def index
    @stops = Stop.all

    render json: @stops
  end

  # GET /stops/1
  def show
    render json: @stop
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stop
    @stop = Stop.find(params[:id])
  end
end
