# frozen_string_literal: true

require Rails.root.join('lib/gtfs_realtime/gtfs-realtime_pb').to_s

##
# Fetches and decodes GTFS-realtime feeds once per TTL. Each fill caches both the raw
# decoded entities and the rendered /realtime JSON, so readers never decode again.
class RealtimeFeeds
  CACHE_TTL = 5.seconds
  RACE_CONDITION_TTL = 5.seconds

  URL_ENV = {
    alerts: 'GTFS_REALTIME_ALERTS_URL',
    trip_updates: 'GTFS_REALTIME_TRIP_UPDATES_URL',
    vehicle_positions: 'GTFS_REALTIME_VEHICLE_POSITIONS_URL'
  }.freeze

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

  class << self
    def configured?(feed)
      ENV.fetch(URL_ENV.fetch(feed), nil).present?
    end

    # Rendered JSON body for /realtime/<feed>.json
    def json(feed)
      cached(feed, :json)
    end

    # Decoded entities as symbol-keyed hashes, enums left as integers
    def entities(feed)
      cached(feed, :entities)
    end

    private

    def cached(feed, kind)
      Rails.cache.fetch(cache_key(feed, kind), expires_in: CACHE_TTL, race_condition_ttl: RACE_CONDITION_TTL) do
        loaded = load(feed)
        other = kind == :json ? :entities : :json
        Rails.cache.write(cache_key(feed, other), loaded[other], expires_in: CACHE_TTL)
        loaded[kind]
      end
    end

    def cache_key(feed, kind)
      "realtime_feeds/#{feed}/#{kind}"
    end

    def load(feed)
      data = RealtimeFeedClient.new.fetch(ENV.fetch(URL_ENV.fetch(feed), nil))
      descriptor = TransitRealtime::FeedEntity.descriptor
      entities = TransitRealtime::FeedMessage.decode(data).entity.map { |entity| legacy_hash(entity.to_h, descriptor) }
      presented = entities.map { |entity| send(:"present_#{feed.to_s.singularize}", entity.deep_dup) }
      { entities:, json: presented.to_json }
    end

    # Matches the hash the pure-Ruby protobuf gem produced: only fields present on the wire,
    # in tag order, enums as integers, and enum values outside the schema dropped.
    def legacy_hash(hash, descriptor)
      legacy_fields(descriptor).each_with_object({}) do |(key, type, repeated, subtype), result|
        next unless hash.key?(key)

        value = hash[key]
        if repeated
          result[key] = value.filter_map { |item| legacy_value(item, type, subtype) } unless value.empty?
        else
          converted = legacy_value(value, type, subtype)
          result[key] = converted unless converted.nil?
        end
      end
    end

    def legacy_value(value, type, subtype)
      case type
      when :message then legacy_hash(value, subtype)
      when :enum then subtype.lookup_name(value) if value.is_a?(Symbol)
      else value
      end
    end

    def legacy_fields(descriptor)
      @legacy_fields ||= {}
      @legacy_fields[descriptor] ||= descriptor.sort_by(&:number).map do |field|
        [field.name.to_sym, field.type, field.label == :repeated, field.subtype]
      end
    end

    def present_alert(entity)
      entity[:alert][:cause] = ALERT_CAUSES[entity[:alert][:cause]] unless entity[:alert][:cause].nil?
      entity[:alert][:effect] = ALERT_EFFECTS[entity[:alert][:effect]] unless entity[:alert][:effect].nil?
      entity[:alert][:informed_entity]&.each do |informed_entity|
        relationship = informed_entity.dig(:trip, :schedule_relationship)
        informed_entity[:trip][:schedule_relationship] = TRIP_SCHEDULE_RELATIONSHIPS[relationship] unless relationship.nil?
      end
      entity
    end

    def present_vehicle_position(entity)
      status = entity[:vehicle][:occupancy_status]
      entity[:vehicle][:occupancy_status] = OCCUPANCY_STATUSES[status] unless status.nil?
      entity
    end

    def present_trip_update(entity)
      trip = entity[:trip_update][:trip]
      trip[:schedule_relationship] = TRIP_SCHEDULE_RELATIONSHIPS[trip[:schedule_relationship]] unless trip[:schedule_relationship].nil?
      entity[:trip_update][:stop_time_update]&.each do |stop_time|
        relationship = stop_time[:schedule_relationship]
        stop_time[:schedule_relationship] = STOP_TIME_SCHEDULE_RELATIONSHIPS[relationship] unless relationship.nil?
      end
      entity
    end
  end
end
