class TransfersController < ApplicationController
  before_action :set_transfer, only: [:show]

  # GET /transfers
  def index
    render json: paginate_results(Transfer.all)
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
