class CalendarDatesController < ApplicationController
  before_action :set_calendar_date, only: [:show]

  # GET /calendar_dates
  def index
    render json: paginate_results(CalendarDate.all)
  end

  # GET /calendar_dates/1
  def show
    render json: paginate_results(@calendar_date)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_calendar_date
    @calendar_date = CalendarDate.where(service_gid: params[:service_gid])
    raise ActionController::RoutingError.new('Not Found') if @calendar_date.nil?
  end
end
