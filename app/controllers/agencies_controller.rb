class AgenciesController < ApplicationController
  before_action :set_agency, only: [:show]

  # GET /agencies
  def index
    render json: paginate_results(Agency.all)
  end

  # GET /agencies/1
  def show
    render json: @agency
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_agency
    @agency = Agency.find_by_agency_gid(params[:agency_gid])
    raise ActiveRecord::RecordNotFound if @agency.nil?
  end
end
