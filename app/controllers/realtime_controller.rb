require 'protobuf'
require 'google/transit/gtfs-realtime.pb'

class RealtimeController < ApplicationController
  class MissingConfiguration < StandardError
  end

  ALERT_CAUSES = {
    0 => nil,
    1 => 'Unknown Cause',
    2 => 'Other Cause',
    3 => 'Technical Problem',
    4 => 'Strike',
    5 => 'Demonstration',
    6 => 'Accident',
    7 => 'Holiday',
    8 => 'Weather',
    9 => 'Maintenance',
    10 => 'Construction',
    11 => 'Police Activity',
    12 => 'Medical Emergency'
  }.freeze

  ALERT_EFFECTS = {
    0 => nil,
    1 => 'No Service',
    2 => 'Reduced Service',
    3 => 'Significant Delays',
    4 => 'Detour',
    5 => 'Additional Service',
    6 => 'Modified Service',
    7 => 'Other Effect',
    8 => 'Unknown Effect',
    9 => 'Stop Moved'
  }.freeze

  def alerts
    raise MissingConfiguration, 'Missing GTFS_REALTIME_ALERTS_URL' if ENV['GTFS_REALTIME_ALERTS_URL'].nil?
    expires_in 10.seconds, public: true
    Rails.cache.fetch('/realtime/alerts.json', expires_in: 10.seconds) do
      alerts = []
      data = Net::HTTP.get(URI.parse(ENV['GTFS_REALTIME_ALERTS_URL']))
      feed = Transit_realtime::FeedMessage.decode(data)
      feed.entity.each do |entity|
        entity = entity.to_hash
        entity[:alert][:cause] = ALERT_CAUSES[entity[:alert][:cause]] unless entity[:alert][:cause].nil?
        entity[:alert][:effect] = ALERT_EFFECTS[entity[:alert][:effect]] unless entity[:alert][:effect].nil?
        alerts << entity
      end
      render json: alerts
    end
  end

  def vehicle_positions
    raise MissingConfiguration, 'Missing GTFS_REALTIME_VEHICLE_POSITIONS_URL' if ENV['GTFS_REALTIME_VEHICLE_POSITIONS_URL'].nil?
    expires_in 10.seconds, public: true
    Rails.cache.fetch('/realtime/vehicle_positions.json', expires_in: 10.seconds) do
      positions = []
      data = Net::HTTP.get(URI.parse(ENV['GTFS_REALTIME_VEHICLE_POSITIONS_URL']))
      feed = Transit_realtime::FeedMessage.decode(data)
      feed.entity.each do |entity|
        positions << entity
      end
      render json: positions.to_json
    end
  end

  def trip_updates
    raise MissingConfiguration, 'Missing GTFS_REALTIME_TRIP_UPDATES_URL' if ENV['GTFS_REALTIME_TRIP_UPDATES_URL'].nil?
    expires_in 10.seconds, public: true
    Rails.cache.fetch('/realtime/trip_updates.json', expires_in: 10.seconds) do
      updates = []
      data = Net::HTTP.get(URI.parse(ENV['GTFS_REALTIME_TRIP_UPDATES_URL']))
      feed = Transit_realtime::FeedMessage.decode(data)
      feed.entity.each do |entity|
        updates << entity
      end
      render json: updates.to_json
    end
  end
end
