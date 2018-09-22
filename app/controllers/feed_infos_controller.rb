class FeedInfosController < ApplicationController
  before_action :set_feed_info, only: [:show]

  # GET /feed_infos
  def index
    @feed_infos = FeedInfo.all

    render json: @feed_infos
  end

  # GET /feed_infos/1
  def show
    render json: @feed_info
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_feed_info
    @feed_info = FeedInfo.find(params[:id])
  end
end
