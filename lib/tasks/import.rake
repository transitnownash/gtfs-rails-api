namespace :import do
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

  desc 'Imports data from configured feed'
  task load: :environment do
    Rake::Task['import:clean'].invoke
    raise 'You must set the GTFS_URL variable.' if ENV['GTFS_URL'].empty?

    puts "Retrieving data from #{ENV['GTFS_URL']}"
    source = GTFS::Source.build ENV['GTFS_URL']

    puts 'Processing data'
    source.each_agency do |row|
      Agency.import(row)
    end
    source.each_calendar_date do |row|
      CalendarDate.import(row)
    end
    source.each_calendar do |row|
      Calendar.import(row)
    end
    # source.each_fare_attribute do |row|
    # end
    # source.each_fare_rule do |row|
    # end
    # source.each_frequency do |row|
    # end
    # source.each_route do |row|
    # end
    # source.each_shape do |row|
    # end
    # source.each_stop_time do |row|
    # end
    source.each_stop do |row|
      Stop.import(row)
    end
    # source.each_transfer do |row|
    # end
    # source.each_trip do |row|
    # end
    puts 'Complete!'
    exit 0
  end
end
