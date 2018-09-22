class TransfersController < ApplicationController
  before_action :set_transfer, only: [:show]

  # GET /transfers
  def index
    @transfers = Transfer.all

    render json: @transfers
  end

  # GET /transfers/1
  def show
    render json: @transfer
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_transfer
    @transfer = Transfer.find(params[:id])
  end
end
