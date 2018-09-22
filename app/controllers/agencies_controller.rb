class AgenciesController < ApplicationController
  before_action :set_agency, only: [:show]

  # GET /agencies
  def index
    @agencies = Agency.all

    render json: @agencies
  end

  # GET /agencies/1
  def show
    render json: @agency
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_agency
    @agency = Agency.find(params[:id])
  end
end
