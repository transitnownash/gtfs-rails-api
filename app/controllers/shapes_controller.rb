class ShapesController < ApplicationController
  before_action :set_shape, only: [:show]

  # GET /shapes
  def index
    @shapes = Shape.all

    render json: @shapes
  end

  # GET /shapes/1
  def show
    render json: @shape
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_shape
    @shape = Shape.find(params[:id])
  end
end
