class FrequenciesController < ApplicationController
  before_action :set_frequency, only: [:show]

  # GET /frequencies
  def index
    @frequencies = Frequency.all

    render json: @frequencies
  end

  # GET /frequencies/1
  def show
    render json: @frequency
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_frequency
    @frequency = Frequency.find(params[:id])
  end
end
