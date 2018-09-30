class CalendarsController < ApplicationController
  before_action :set_calendar, only: [:show]

  # GET /calendars
  def index
    render json: paginate_results(Calendar.all)
  end

  # GET /calendars/1
  def show
    render json: @calendar
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_calendar
    @calendar = Calendar.find(params[:id])
  end
end
