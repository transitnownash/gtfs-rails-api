class CalendarsController < ApplicationController
  before_action :set_calendar, only: [:show, :show_trips, :show_calendar_dates]

  # GET /calendars
  def index
    render json: paginate_results(Calendar.all)
  end

  # GET /calendars/1
  def show
    render json: @calendar
  end

  # GET /calendars/1/trips
  def show_trips
    render json: paginate_results(@calendar.trips)
  end

  # GET /calendars/1/calendar_dates
  def show_calendar_dates
    render json: paginate_results(@calendar.calendar_dates)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_calendar
    @calendar = Calendar.find_by_service_gid(params[:service_gid])
  end
end
