namespace :import do
  desc 'Truncates existing tables'
  task clean: :environment do |t|
    puts "Running #{t}"
    puts "#{Time.new}"
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
    puts "#{Time.new}"
  end

  desc 'Imports data from configured feed'
  task load: :environment do
    Rake::Task['import:clean'].invoke
    raise 'You must set the GTFS_URL variable.' if ENV['GTFS_URL'].nil?

    puts "#{Time.new}"
    puts "Retrieving data from #{ENV['GTFS_URL']}"
    source = GTFS::Source.build ENV['GTFS_URL']

    puts 'Processing data'

    begin
      Agency.bulk_insert do |worker|
        source.each_agency do |row|
          worker.add(Agency.hashFromGtfs(row))
        end
      end
    rescue => e
      puts e.message
    end

    begin
      source.each_calendar_date do |row|
        CalendarDate.import(row)
      end
    rescue => e
      puts e.message
    end

    begin
      source.each_calendar do |row|
        Calendar.import(row)
      end
    rescue => e
      puts e.message
    end

    begin
      source.each_fare_attribute do |row|
        FareAttribute.import(row)
      end
    rescue => e
      puts e.message
    end

    begin
      source.each_fare_rule do |row|
        FareRule.import(row)
      end

    rescue => e
      puts e.message
    end

    begin
      FeedInfo.bulk_insert do |worker|
        source.each_feed_info do |row|
          printf("\rFeed Info: #{row.publisher_name}                          ")
          worker.add(FeedInfo.hashFromGtfs(row))
        end
      end
      printf("\rFeed Info: done!                                            \n")
    rescue => e
      puts e.message
    end

    begin
      source.each_frequency do |row|
        Frequency.import(row)
      end

    rescue => e
      puts e.message
    end

    begin
      source.each_route do |row|
        printf("\rRoutes: Route #{row.id} / #{row.long_name}                  ")
        Route.import(row)
      end
      printf("\rRoutes: done!                                               \n")
    rescue => e
      puts e.message
    end

    begin
      Shape.bulk_insert do |worker|
        source.each_shape do |row|
          printf("\rShapes: Shape #{row.id} / #{row.pt_sequence}              ")
          worker.add(Shape.hashFromGtfs(row))
        end
      end
      printf("\rShapes: done!                                               \n")
    rescue => e
      puts e.message
    end

    begin
      StopTime.bulk_insert do |worker|
        source.each_stop_time do |row|
          printf("\rStop Time: Trip #{row.trip_id} / #{row.stop_id}           ")
          worker.add(StopTime.hashFromGtfs(row))
        end
      end
      printf("\rStop Time: done!                                            \n")
    rescue => e
      puts e.message
    end

    begin
      source.each_stop do |row|
        Stop.import(row)
      end
    rescue => e
      puts e.message
    end

    begin
      source.each_transfer do |row|
        Transfer.import(row)
      end
    rescue => e
      puts e.message
    end

    begin
      source.each_trip do |row|
        Trip.import(row)
      end
    rescue => e
      puts e.message
    end

    puts 'Complete!'
    puts "#{Time.new}"
    exit 0
  end
end
