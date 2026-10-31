# frozen_string_literal: true

##
# Realtime Controller
class RealtimeController < ApplicationController
  CACHE_TTL = RealtimeFeeds::CACHE_TTL

  def alerts
    render_feed(:alerts)
  end

  def vehicle_positions
    render_feed(:vehicle_positions)
  end

  def trip_updates
    render_feed(:trip_updates)
  end

  private

  def render_feed(feed)
    env_name = RealtimeFeeds::URL_ENV.fetch(feed)
    return render json: { error: "Missing #{env_name}" }, status: :service_unavailable unless RealtimeFeeds.configured?(feed)

    expires_in CACHE_TTL, public: true
    render json: RealtimeFeeds.json(feed)
  rescue StandardError => e
    Rails.logger.error("Realtime #{feed} error: #{e.class}: #{e.message}")
    render json: { error: 'Realtime data unavailable', data: [] }, status: :service_unavailable
  end
end
