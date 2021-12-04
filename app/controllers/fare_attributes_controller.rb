class FareAttributesController < ApplicationController
  before_action :set_fare_attribute, only: [:show]

  # GET /fare_attributes
  def index
    render json: paginate_results(FareAttribute.all)
  end

  # GET /fare_attributes/1
  def show
    render json: @fare_attribute
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_fare_attribute
    @fare_attribute = FareAttribute.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') if @fare_attribute.nil?
  end
end
