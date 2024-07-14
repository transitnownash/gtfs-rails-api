# frozen_string_literal: true

namespace :clean do
  task default: 'clean:all'

  desc 'Truncates existing tables'
  task all: :environment do |t|
    puts "Running #{t}"
    Rake::Task['clean:agency'].invoke
    Rake::Task['clean:calendar_dates'].invoke
    Rake::Task['clean:calendars'].invoke
    Rake::Task['clean:fare_attributes'].invoke
    Rake::Task['clean:fare_rules'].invoke
    Rake::Task['clean:feed_info'].invoke
    Rake::Task['clean:frequencies'].invoke
    Rake::Task['clean:routes'].invoke
    Rake::Task['clean:shapes'].invoke
    Rake::Task['clean:stop_times'].invoke
    Rake::Task['clean:stops'].invoke
    Rake::Task['clean:transfers'].invoke
    Rake::Task['clean:trips'].invoke
    puts "Finished #{t}"
  end

  desc 'Truncate agency'
  task agency: :environment do |t|
    puts "Running #{t}"

    Agency.delete_all
  end

  desc 'Truncate stops'
  task stops: :environment do |t|
    puts "Running #{t}"
    Stop.delete_all
  end

  desc 'Truncate routes'
  task routes: :environment do |t|
    puts "Running #{t}"
    Route.delete_all
  end

  desc 'Truncate calendar'
  task calendars: :environment do |t|
    puts "Running #{t}"
    Calendar.delete_all
  end

  desc 'Truncate calendar_dates'
  task calendar_dates: :environment do |t|
    puts "Running #{t}"
    CalendarDate.delete_all
  end

  desc 'Truncate shapes'
  task shapes: :environment do |t|
    puts "Running #{t}"
    Shape.delete_all
  end

  desc 'Truncate trips'
  task trips: :environment do |t|
    puts "Running #{t}"
    Trip.delete_all
  end

  desc 'Truncate stop_times'
  task stop_times: :environment do |t|
    puts "Running #{t}"
    StopTime.delete_all
  end

  desc 'Truncate fare_attributes'
  task fare_attributes: :environment do |t|
    puts "Running #{t}"
    FareAttribute.delete_all
  end

  desc 'Truncate fare_rules'
  task fare_rules: :environment do |t|
    puts "Running #{t}"
    FareRule.delete_all
  end

  desc 'Truncate frequencies'
  task frequencies: :environment do |t|
    puts "Running #{t}"
    Frequency.delete_all
  end

  desc 'Truncate transfers'
  task transfers: :environment do |t|
    puts "Running #{t}"
    Transfer.delete_all
  end

  desc 'Truncate feed_info'
  task feed_info: :environment do |t|
    puts "Running #{t}"
    FeedInfo.delete_all
  end
end
