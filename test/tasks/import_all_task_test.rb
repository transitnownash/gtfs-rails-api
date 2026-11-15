# frozen_string_literal: true

require 'test_helper'
require 'rake'

class ImportAllTaskTest < ActiveSupport::TestCase
  Rails.application.load_tasks unless Rake::Task.task_defined?('import:all')

  setup do
    @original_gtfs_url = ENV.fetch('GTFS_URL', nil)
    @zip = Rails.root.join('tmp', "gtfs-fixture-#{Process.pid}.zip").to_s
    FileUtils.rm_f(@zip)
    Zip::File.open(@zip, create: true) do |zip|
      Dir[file_fixture('gtfs').join('*.txt')].each { |f| zip.add(File.basename(f), f) }
    end
    ENV['GTFS_URL'] = @zip
    Rake::Task.tasks.each(&:reenable)
  end

  teardown do
    ENV['GTFS_URL'] = @original_gtfs_url
    FileUtils.rm_f(@zip)
    Rake::Task.tasks.each(&:reenable)
  end

  test 'import:all loads every GTFS file and links records' do
    capture_io { Rake::Task['import:all'].invoke }

    assert_equal 1, Agency.count
    assert_equal 3, Stop.count
    assert_equal 1, Route.count
    assert_equal 1, Calendar.count
    assert_equal 1, CalendarDate.count
    assert_equal 1, Shape.count
    assert_equal 2, Trip.count
    assert_equal 4, StopTime.count
    assert_equal 1, FareAttribute.count
    assert_equal 1, FareRule.count
    assert_equal 1, Frequency.count
    assert_equal 1, Transfer.count
    assert_equal 1, FeedInfo.count

    assert_equal Agency.first.id, Route.first.agency_id
    assert_equal Stop.find_by(stop_gid: 'CENT').id, Stop.find_by(stop_gid: 'CENT_A').parent_station_id
    assert_equal 2, JSON.parse(Shape.first.shape_points).size

    t1 = Trip.find_by(trip_gid: 'T1')
    assert_equal Shape.first.id, t1.shape_id
    assert_nil Trip.find_by(trip_gid: 'T2').shape_id
    assert_nil StopTime.find_by(stop_gid: 'MISSING').stop_id
    assert_not_nil t1.start_time
    assert_not_nil t1.end_time
  end
end
