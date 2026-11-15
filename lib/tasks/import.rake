# frozen_string_literal: true

namespace :import do
  task default: 'import:all'

  desc 'Import all data into staging tables, validate, then swap them live (FORCE=1 skips the shrink guard)'
  task all: :environment do |_t|
    Rake::Task['import:verify'].invoke
    GtfsImport.prepare_staging!

    begin
      GtfsImport.with_staging do
        %w[
          agency stops routes calendar calendar_dates shapes trips stop_times fare_attributes
          fare_rules frequencies transfers feed_info set_parent_stops trips_start_end apply_overrides
        ].each { |name| Rake::Task["import:#{name}"].invoke }

        GtfsImport.validate_staging!(force: ENV['FORCE'] == '1')
      end
    rescue GtfsImport::ValidationError => e
      puts "[ERROR] #{e.message}"
      puts '[ERROR] Import rejected; live tables were not changed.'
      GtfsImport.drop_tables!('_staging')
      exit 1
    end

    GtfsImport.swap!
    puts "Swapped in new data: #{GtfsImport::MODELS.map { |m| "#{m.table_name}=#{m.count}" }.join(' ')}"
  end

  desc 'Restore the data replaced by the last import:all (restart the app afterwards)'
  task rollback: :environment do |t|
    puts "Running #{t}"
    GtfsImport.rollback!
    puts "Finished #{t}"
  rescue GtfsImport::ValidationError => e
    puts "[ERROR] #{e.message}"
    exit 1
  end

  desc 'Verifies configured GTFS feed is valid'
  task verify: :environment do |t|
    puts "Running #{t}"
    gtfs_url = ENV.fetch('GTFS_URL', nil)

    if gtfs_url.blank?
      puts '[ERROR] GTFS_URL is not configured.'
      exit 1
    end

    begin
      @source = GTFS::Source.build(gtfs_url)
      puts "Finished #{t}"
    rescue GTFS::InvalidSourceException => e
      puts "[ERROR] #{e.message}"
      puts "[ERROR] GTFS zip at #{gtfs_url} is invalid."
      exit 1
    end
  end

  desc 'Imports agency.txt'
  task agency: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(Agency, @source.enum_for(:each_agency).lazy.map { |row| Agency.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] agency.txt does not exist.'
    end
  end

  desc 'Imports calendar_dates.txt'
  task calendar_dates: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      @source.each_calendar_date do |row|
        date = CalendarDate.new(CalendarDate.hash_from_gtfs(row))
        if date.calendar_id.nil?
          puts "[ERROR] Calendar ID is nil for #{date.inspect}"
          next
        end

        date.save
      end
    rescue Errno::ENOENT
      puts '[warning] calendar_dates.txt does not exist.'
    end
  end

  desc 'Imports calendar.txt'
  task calendar: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(Calendar, @source.enum_for(:each_calendar).lazy.map { |row| Calendar.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] calendar.txt does not exist.'
    end
  end

  desc 'Imports fare_attributes.txt'
  task fare_attributes: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(FareAttribute, @source.enum_for(:each_fare_attribute).lazy.map { |row| FareAttribute.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] fare_attributes.txt does not exist.'
    end
  end

  desc 'Imports fare_rules.txt'
  task fare_rules: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(FareRule, @source.enum_for(:each_fare_rule).lazy.map { |row| FareRule.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] fare_rules.txt does not exist.'
    end
  end

  desc 'Imports feed_info.txt'
  task feed_info: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(FeedInfo, @source.enum_for(:each_feed_info).lazy.map { |row| FeedInfo.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] feed_info.txt does not exist.'
    end
  end

  desc 'Imports frequencies.txt'
  task frequencies: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(Frequency, @source.enum_for(:each_frequency).lazy.map { |row| Frequency.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] frequencies.txt does not exist.'
    end
  end

  desc 'Imports routes.txt'
  task routes: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(Route, @source.enum_for(:each_route).lazy.map { |row| Route.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] routes.txt does not exist.'
    end
  end

  desc 'Imports shapes.txt'
  task shapes: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      shapes = {}
      @source.each_shape do |row|
        shapes[row.id] = { shape_gid: row.id, shape_points: [] } unless shapes[row.id]
        shapes[row.id][:shape_points] << {
          lat: row.pt_lat,
          lon: row.pt_lon,
          sequence: row.pt_sequence,
          dist_traveled: row.dist_traveled
        }
      end
      # Reconnect database (previous block hits timeout limit)
      ActiveRecord::Base.connection_handler.clear_active_connections!
      GtfsImport.bulk_load(Shape, shapes.each_value.lazy.map { |row| Shape.hash_from_gtfs(row) }, batch_size: 25, upsert: false)
    rescue Errno::ENOENT
      puts '[warning] shapes.txt does not exist.'
    end
  end

  desc 'Imports stop_times.txt'
  task stop_times: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(StopTime, @source.enum_for(:each_stop_time).lazy.map { |row| StopTime.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] stop_times.txt does not exist.'
    end
  end

  desc 'Imports stops.txt'
  task stops: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(Stop, @source.enum_for(:each_stop).lazy.map { |row| Stop.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] stops.txt does not exist.'
    end
  end

  desc 'Set parent stop if null'
  task set_parent_stops: :environment do |t|
    puts "Running #{t}"
    Stop.where.not(parent_station_gid: nil).each do |stop|
      stop.parent_station_id = Stop.find_by(stop_gid: stop.parent_station_gid).id
      stop.save!
    end
  end

  desc 'Imports transfers.txt'
  task transfers: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(Transfer, @source.enum_for(:each_transfer).lazy.map { |row| Transfer.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] transfers.txt does not exist.'
    end
  end

  desc 'Import trips.txt'
  task trips: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      GtfsImport.bulk_load(Trip, @source.enum_for(:each_trip).lazy.map { |row| Trip.hash_from_gtfs(row) })
    rescue Errno::ENOENT
      puts '[warning] trips.txt does not exist.'
    end
  end

  desc 'Calculate start / end times for trips'
  task trips_start_end: :environment do |t|
    puts "Running #{t}"

    trips_to_update = []

    Trip.includes(:stop_times).find_each(batch_size: 1000) do |trip|
      stop_times = trip.stop_times
      next unless stop_times.count.positive?

      trip.start_time = stop_times.first.departure_time
      trip.end_time = stop_times.last.arrival_time

      trips_to_update << trip if trip.valid?
    end

    # Bulk update all trips that need updating
    unless trips_to_update.empty?
      Trip.transaction do
        Trip.import(trips_to_update, on_duplicate_key_update: %i[start_time end_time])
      end
    end
  end

  desc 'Apply data overrides'
  task apply_overrides: :environment do |t|
    next unless Rails.root.join('overrides.yml').exist?

    puts "Running #{t}"
    overrides = YAML.safe_load Rails.root.join('overrides.yml').read
    overrides.each do |override|
      instance = override['class'].constantize
      instance.where(override['where']).update_all(override['update'])
    end
  end
end
