# frozen_string_literal: true

##
# Fare Rules Controller
class FareRulesController < ApplicationController
  before_action :set_fare_rule, only: [:show]

  # GET /fare_rules
  def index
    render json: paginate_results(FareRule.all)
  end

  # GET /fare_rules/1
  def show
    render json: @fare_rule
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_fare_rule
    @fare_rule = FareRule.find(params[:id])
    raise ActionController::RoutingError, 'Not Found' if @fare_rule.nil?
  end
end
