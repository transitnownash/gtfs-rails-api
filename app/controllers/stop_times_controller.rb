# frozen_string_literal: true

##
# Stop Times Controller
class StopTimesController < ApplicationController
  # GET /stop_times
  def index
    render json: paginate_results(StopTime.all)
  end
end
