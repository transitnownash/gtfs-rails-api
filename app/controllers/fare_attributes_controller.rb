class FareAttributesController < ApplicationController
  before_action :set_fare_attribute, only: [:show]

  # GET /fare_attributes
  def index
    @fare_attributes = FareAttribute.all

    render json: @fare_attributes
  end

  # GET /fare_attributes/1
  def show
    render json: @fare_attribute
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_fare_attribute
    @fare_attribute = FareAttribute.find(params[:id])
  end
end
