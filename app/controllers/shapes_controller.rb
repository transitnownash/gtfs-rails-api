class ShapesController < ApplicationController
  before_action :set_shape, only: [:show, :update, :destroy]

  # GET /shapes
  def index
    @shapes = Shape.all

    render json: @shapes
  end

  # GET /shapes/1
  def show
    render json: @shape
  end

  # POST /shapes
  def create
    @shape = Shape.new(shape_params)

    if @shape.save
      render json: @shape, status: :created, location: @shape
    else
      render json: @shape.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /shapes/1
  def update
    if @shape.update(shape_params)
      render json: @shape
    else
      render json: @shape.errors, status: :unprocessable_entity
    end
  end

  # DELETE /shapes/1
  def destroy
    @shape.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shape
      @shape = Shape.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def shape_params
      params.fetch(:shape, {})
    end
end
