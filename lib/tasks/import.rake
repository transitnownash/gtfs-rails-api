# frozen_string_literal: true

namespace :import do
  task default: 'import:all'

  desc 'Import all available data'
  task all: :environment do
    Rake::Task['import:clean'].invoke

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

  desc 'Truncates existing tables'
  task clean: :environment do |t|
    puts "Running #{t}"
    Agency.delete_all
    CalendarDate.delete_all
    Calendar.delete_all
    FareAttribute.delete_all
    FareRule.delete_all
    FeedInfo.delete_all
    Frequency.delete_all
    Route.delete_all
    Shape.delete_all
    StopTime.delete_all
    Stop.delete_all
    Transfer.delete_all
    Trip.delete_all
    puts "Finished #{t}"
  end

  desc 'Imports agency.txt'
  task agency: :environment do
    puts 'agency.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Agency.bulk_insert do |worker|
        @source.each_agency do |row|
          worker.add(Agency.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Imports calendar_dates.txt'
  task calendar_dates: :environment do
    puts 'calendar_dates.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      CalendarDate.bulk_insert do |worker|
        @source.each_calendar_date do |row|
          worker.add(CalendarDate.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Imports calendar.txt'
  task calendar: :environment do
    puts 'calendar.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Calendar.bulk_insert do |worker|
        @source.each_calendar do |row|
          worker.add(Calendar.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Imports fare_attributes.txt'
  task fare_attributes: :environment do
    puts 'fare_attributes.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      FareAttribute.bulk_insert do |worker|
        @source.each_fare_attribute do |row|
          worker.add(FareAttribute.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Imports data from configured feed'
  task fare_rules: :environment do
    puts 'fare_rules.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      FareRule.bulk_insert do |worker|
        @source.each_fare_rule do |row|
          worker.add(FareRule.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Imports feed_info.txt'
  task feed_info: :environment do
    puts 'feed_info.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      FeedInfo.bulk_insert do |worker|
        @source.each_feed_info do |row|
          worker.add(FeedInfo.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Imports frequencies.txt'
  task frequencies: :environment do
    puts 'frequencies.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Frequency.bulk_insert do |worker|
        @source.each_frequency do |row|
          worker.add(Frequency.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Imports routes.txt'
  task routes: :environment do
    puts 'routes.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Route.bulk_insert do |worker|
        @source.each_route do |row|
          worker.add(Route.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Imports shapes.txt'
  task shapes: :environment do
    puts 'shapes.txt'
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
      puts '[warning] File does not exist.'
    end
  end

  desc 'Imports stop_times.txt'
  task stop_times: :environment do
    puts 'stop_times.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      StopTime.bulk_insert do |worker|
        @source.each_stop_time do |row|
          worker.add(StopTime.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Imports stops.txt'
  task stops: :environment do
    puts 'stops.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Stop.bulk_insert do |worker|
        @source.each_stop do |row|
          worker.add(Stop.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Set parent stop if null'
  task set_parent_stops: :environment do
    puts 'Setting parent stations ...'
    Stop.where.not(parent_station_gid: nil).each do |stop|
      stop.parent_station_id = Stop.find_by(stop_gid: stop.parent_station_gid).id
      stop.save!
    end
  end

  desc 'Imports transfers.txt'
  task transfers: :environment do
    puts 'transfers.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Transfer.bulk_insert do |worker|
        @source.each_transfer do |row|
          worker.add(Transfer.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Import trips.txt'
  task trips: :environment do
    puts 'trips.txt'
    begin
      @source = GTFS::Source.build ENV.fetch('GTFS_URL', nil)
      Trip.bulk_insert do |worker|
        @source.each_trip do |row|
          worker.add(Trip.hash_from_gtfs(row))
        end
      end
    rescue Errno::ENOENT
      puts '[warning] File does not exist.'
    end
  end

  desc 'Calculate start / end times for trips'
  task trips_start_end: :environment do
    puts 'Adding start/end times to trips ...'
    Trip.all.each do |trip|
      stop_times = trip.stop_times
      next unless trip.stop_times.count.positive?

      trip.start_time = stop_times.first.departure_time
      trip.end_time = stop_times.last.arrival_time
      trip.save!
    end
  end

  desc 'Apply data overrides'
  task apply_overrides: :environment do
    return unless File.exist? Rails.root.join('overrides.yml')

    puts 'Applying data overrides ...'
    overrides = YAML.safe_load File.read(Rails.root.join('overrides.yml'))
    overrides.each do |override|
      instance = override['class'].constantize
      instance.where(override['where']).update_all(override['update'])
    end
  end
end
