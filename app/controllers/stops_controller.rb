class StopsController < ApplicationController
  before_action :set_stop, only: [:show]

  # GET /stops
  def index
    render json: paginate_results(Stop.all)
  end

  # GET /stops/1
  def show
    render json: @stop
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stop
    @stop = Stop.find_by_stop_gid(params[:stop_gid])
    raise 'NotFoundException' if @stop.nil?
  end
end
