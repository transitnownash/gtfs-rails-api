# frozen_string_literal: true

##
# Feed Infos Controller
class FeedInfosController < ApplicationController
  before_action :set_feed_info, only: [:show]

  # GET /feed_info
  def index
    render json: paginate_results(FeedInfo.all)
  end

  # GET /feed_info/1
  def show
    render json: @feed_info
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_feed_info
    @feed_info = FeedInfo.find(params[:id])
    raise ActionController::RoutingError, 'Not Found' if @feed_info.nil?
  end
end
