class FareRulesController < ApplicationController
  before_action :set_fare_rule, only: [:show]

  # GET /fare_rules
  def index
    @fare_rules = FareRule.all

    render json: @fare_rules
  end

  # GET /fare_rules/1
  def show
    render json: @fare_rule
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_fare_rule
    @fare_rule = FareRule.find(params[:id])
  end
end
