# frozen_string_literal: true

require 'protobuf'
require 'google/transit/gtfs-realtime.pb'

##
# Realtime Controller
class RealtimeController < ApplicationController
  CACHE_TTL = 5

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
    9 => 'Stop Moved',
    10 => 'No Effect',
    11 => 'Accessibility Issue'
  }.freeze

  OCCUPANCY_STATUSES = {
    0 => 'Empty',
    1 => 'Many Seats Available',
    2 => 'Few Seats Available',
    3 => 'Standing Room Only',
    4 => 'Crushed Standing Room Only',
    5 => 'Full',
    6 => 'Not Accepting Passengers',
    7 => 'No Data Available',
    8 => 'Not Boardable'
  }.freeze

  TRIP_SCHEDULE_RELATIONSHIPS = {
    0 => 'Scheduled',
    1 => 'Added', # deprecated in spec but still possible in feeds
    2 => 'Unscheduled',
    3 => 'Canceled',
    5 => 'Replacement',
    6 => 'Duplicated',
    7 => 'Deleted',
    8 => 'New'
  }.freeze

  STOP_TIME_SCHEDULE_RELATIONSHIPS = {
    0 => 'Scheduled',
    1 => 'Skipped',
    2 => 'No Data',
    3 => 'Unscheduled'
  }.freeze

  def alerts
    return render json: 'Missing GTFS_REALTIME_ALERTS_URL' unless ENV.fetch 'GTFS_REALTIME_ALERTS_URL'

    expires_in CACHE_TTL.seconds, public: true
    messages = Rails.cache.fetch('/realtime/alerts.json', expires_in: CACHE_TTL.seconds) do
      messages = []
      data = Net::HTTP.get(URI.parse(ENV.fetch('GTFS_REALTIME_ALERTS_URL', nil)))
      feed = Transit_realtime::FeedMessage.decode(data)
      feed.entity.each do |entity|
        entity = entity.to_hash
        entity[:alert][:cause] = ALERT_CAUSES[entity[:alert][:cause]] unless entity[:alert][:cause].nil?
        entity[:alert][:effect] = ALERT_EFFECTS[entity[:alert][:effect]] unless entity[:alert][:effect].nil?
        unless entity[:alert][:informed_entity].nil?
          entity[:alert][:informed_entity] = entity[:alert][:informed_entity].map do |informed_entity|
            unless informed_entity[:trip].nil?
              unless informed_entity[:trip][:schedule_relationship].nil?
                informed_entity[:trip][:schedule_relationship] = TRIP_SCHEDULE_RELATIONSHIPS[informed_entity[:trip][:schedule_relationship]]
              end
            end
            informed_entity
          end
        end
        messages << entity
      end
      messages
    end
    render json: messages
  end

  def vehicle_positions
    return render json: 'Missing GTFS_REALTIME_VEHICLE_POSITIONS_URL' unless ENV.fetch 'GTFS_REALTIME_VEHICLE_POSITIONS_URL'

    expires_in CACHE_TTL.seconds, public: true
    positions = Rails.cache.fetch('/realtime/vehicle_positions.json', expires_in: CACHE_TTL.seconds) do
      positions = []
      data = Net::HTTP.get(URI.parse(ENV.fetch('GTFS_REALTIME_VEHICLE_POSITIONS_URL', nil)))
      feed = Transit_realtime::FeedMessage.decode(data)
      feed.entity.each do |entity|
        entity = entity.to_hash
        entity[:vehicle][:occupancy_status] = OCCUPANCY_STATUSES[entity[:vehicle][:occupancy_status]] unless entity[:vehicle][:occupancy_status].nil?
        positions << entity
      end
      positions
    end
    render json: positions
  end

  def trip_updates
    return render json: 'Missing GTFS_REALTIME_TRIP_UPDATES_URL' unless ENV.fetch 'GTFS_REALTIME_TRIP_UPDATES_URL'

    expires_in CACHE_TTL.seconds, public: true
    updates = Rails.cache.fetch('/realtime/trip_updates.json', expires_in: CACHE_TTL.seconds) do
      updates = []
      data = Net::HTTP.get(URI.parse(ENV.fetch('GTFS_REALTIME_TRIP_UPDATES_URL', nil)))
      feed = Transit_realtime::FeedMessage.decode(data)
      feed.entity.each do |entity|
        entity = entity.to_hash
        unless entity[:trip_update][:trip][:schedule_relationship].nil?
          entity[:trip_update][:trip][:schedule_relationship] = TRIP_SCHEDULE_RELATIONSHIPS[entity[:trip_update][:trip][:schedule_relationship]]
        end
        unless entity[:trip_update][:stop_time_update].nil?
          entity[:trip_update][:stop_time_update] = entity[:trip_update][:stop_time_update].map do |stop_time|
            stop_time[:schedule_relationship] = STOP_TIME_SCHEDULE_RELATIONSHIPS[stop_time[:schedule_relationship]] unless stop_time[:schedule_relationship].nil?
            stop_time
          end
        end
        updates << entity
      end
      updates
    end
    render json: updates.as_json
  end
end
