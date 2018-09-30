class ShapesController < ApplicationController
  before_action :set_shape, only: [:show]

  # GET /shapes
  def index
    render json: paginate_results(Shape.all)
  end

  # GET /shapes/1
  def show
    render json: @shape
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_shape
    @shape = Shape.where(shape_gid: params[:shape_gid])
    raise 'NotFoundException' if @shape.empty?
  end
end
