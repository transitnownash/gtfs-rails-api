class StopsController < ApplicationController
  before_action :set_stop, only: [:show, :update, :destroy]

  # GET /stops
  def index
    @stops = Stop.all

    render json: @stops
  end

  # GET /stops/1
  def show
    render json: @stop
  end

  # POST /stops
  def create
    @stop = Stop.new(stop_params)

    if @stop.save
      render json: @stop, status: :created, location: @stop
    else
      render json: @stop.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /stops/1
  def update
    if @stop.update(stop_params)
      render json: @stop
    else
      render json: @stop.errors, status: :unprocessable_entity
    end
  end

  # DELETE /stops/1
  def destroy
    @stop.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stop
      @stop = Stop.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def stop_params
      params.fetch(:stop, {})
    end
end
