# frozen_string_literal: true

namespace :import do
  task default: 'import:all'

  desc 'Import all available data'
  task all: :environment do |_t|
    Rake::Task['import:verify'].invoke
    Rake::Task['clean:all'].invoke

    Rake::Task['import:agency'].invoke
    Rake::Task['import:stops'].invoke
    Rake::Task['import:routes'].invoke
    Rake::Task['import:calendar'].invoke
    Rake::Task['import:calendar_dates'].invoke
    Rake::Task['import:shapes'].invoke
    Rake::Task['import:trips'].invoke
    Rake::Task['import:stop_times'].invoke
    Rake::Task['import:fare_attributes'].invoke
    Rake::Task['import:fare_rules'].invoke
    Rake::Task['import:frequencies'].invoke
    Rake::Task['import:transfers'].invoke
    Rake::Task['import:feed_info'].invoke
    Rake::Task['import:set_parent_stops'].invoke
    Rake::Task['import:trips_start_end'].invoke
    Rake::Task['import:apply_overrides'].invoke
  end

  desc 'Verifies configured GTFS feed is valid'
  task verify: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      puts "Finished #{t}"
    rescue GTFS::InvalidSourceException => e
      puts "[ERROR] #{e.message}"
      puts "[ERROR] GTFS zip at #{ENV.fetch('GTFS_URL')} is invalid."
      exit 1
    end
  end

  desc 'Imports agency.txt'
  task agency: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Agency.bulk_insert(update_duplicates: true) do |worker|
        @source.each_agency do |row|
          worker.add(Agency.hash_from_gtfs(row))
        end
      end
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
      Calendar.bulk_insert(update_duplicates: true) do |worker|
        @source.each_calendar do |row|
          worker.add(Calendar.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] calendar.txt does not exist.'
    end
  end

  desc 'Imports fare_attributes.txt'
  task fare_attributes: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      FareAttribute.bulk_insert(update_duplicates: true) do |worker|
        @source.each_fare_attribute do |row|
          worker.add(FareAttribute.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] fare_attributes.txt does not exist.'
    end
  end

  desc 'Imports fare_rules.txt'
  task fare_rules: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      FareRule.bulk_insert(update_duplicates: true) do |worker|
        @source.each_fare_rule do |row|
          worker.add(FareRule.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] fare_rules.txt does not exist.'
    end
  end

  desc 'Imports feed_info.txt'
  task feed_info: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      FeedInfo.bulk_insert(update_duplicates: true) do |worker|
        @source.each_feed_info do |row|
          worker.add(FeedInfo.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] feed_info.txt does not exist.'
    end
  end

  desc 'Imports frequencies.txt'
  task frequencies: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Frequency.bulk_insert(update_duplicates: true) do |worker|
        @source.each_frequency do |row|
          worker.add(Frequency.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] frequencies.txt does not exist.'
    end
  end

  desc 'Imports routes.txt'
  task routes: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Route.bulk_insert(update_duplicates: true) do |worker|
        @source.each_route do |row|
          worker.add(Route.hash_from_gtfs(row))
        end
      end
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
      Shape.bulk_insert(set_size: 25) do |worker|
        # Reconnect database (previous block hits timeout limit)
        ActiveRecord::Base.clear_active_connections!
        shapes.each do |_, row|
          worker.add(Shape.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] shapes.txt does not exist.'
    end
  end

  desc 'Imports stop_times.txt'
  task stop_times: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      StopTime.bulk_insert(update_duplicates: true) do |worker|
        @source.each_stop_time do |row|
          worker.add(StopTime.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] stop_times.txt does not exist.'
    end
  end

  desc 'Imports stops.txt'
  task stops: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Stop.bulk_insert(update_duplicates: true) do |worker|
        @source.each_stop do |row|
          worker.add(Stop.hash_from_gtfs(row))
        end
      end
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
      Transfer.bulk_insert(update_duplicates: true) do |worker|
        @source.each_transfer do |row|
          worker.add(Transfer.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] transfers.txt does not exist.'
    end
  end

  desc 'Import trips.txt'
  task trips: :environment do |t|
    puts "Running #{t}"
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Trip.bulk_insert(update_duplicates: true) do |worker|
        @source.each_trip do |row|
          worker.add(Trip.hash_from_gtfs(row))
        end
      end
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
