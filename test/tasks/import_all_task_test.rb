# frozen_string_literal: true

require 'test_helper'
require 'rake'

class ImportAllTaskTest < ActiveSupport::TestCase
  # CREATE/RENAME/DROP TABLE implicitly commit, so a wrapping transaction can't isolate these tests.
  self.use_transactional_tests = false

  Rails.application.load_tasks unless Rake::Task.task_defined?('import:all')

  setup do
    @original_gtfs_url = ENV.fetch('GTFS_URL', nil)
    @zip = Rails.root.join('tmp', "gtfs-fixture-#{Process.pid}.zip").to_s
    ENV['GTFS_URL'] = @zip
    build_feed
    Rake::Task.tasks.each(&:reenable)
  end

  teardown do
    GtfsImport.rollback! if table_exists?('agencies_old')
    GtfsImport.drop_tables!('_staging', '_old')
    ENV['GTFS_URL'] = @original_gtfs_url
    ENV.delete('FORCE')
    FileUtils.rm_f(@zip)
    Rake::Task.tasks.each(&:reenable)
  end

  test 'import:all loads every GTFS file, links records and keeps the prior data' do
    StopTime.delete_all
    Trip.delete_all
    fixture_agency_gid = Agency.first.agency_gid

    run_import

    expected = GtfsImport::MODELS.index_with(1).merge(Stop => 3, Trip => 2, StopTime => 4)
    assert_equal expected, GtfsImport::MODELS.index_with(&:count)

    assert_equal Agency.first.id, Route.first.agency_id
    assert_equal Stop.find_by(stop_gid: 'CENT').id, Stop.find_by(stop_gid: 'CENT_A').parent_station_id
    assert_equal 2, JSON.parse(Shape.first.shape_points).size

    t1 = Trip.find_by(trip_gid: 'T1')
    assert_equal Shape.first.id, t1.shape_id
    assert_nil Trip.find_by(trip_gid: 'T2').shape_id
    assert_nil StopTime.find_by(stop_gid: 'MISSING').stop_id
    assert_not_nil t1.start_time
    assert_not_nil t1.end_time

    assert_equal 'agencies', Agency.table_name
    assert_equal [fixture_agency_gid], select_values('SELECT agency_gid FROM agencies_old')
    assert_not table_exists?('agencies_staging')
  end

  test 'import:all rejects a feed missing required data and leaves live tables untouched' do
    build_feed('stop_times.txt' => "trip_id,arrival_time,departure_time,stop_id,stop_sequence\n")
    live_trips = Trip.count

    stdout = run_import(expect_exit: 1)

    assert_includes stdout, '[ERROR] No records found in: stop_times'
    assert_equal live_trips, Trip.count
    assert_equal 'trips', Trip.table_name
    assert_not table_exists?('trips_staging')
    assert_not table_exists?('trips_old')
  end

  test 'import:all refuses a feed far smaller than live data unless FORCE=1' do
    live_trips = Trip.count
    assert_operator live_trips, :>, 4

    stdout = run_import(expect_exit: 1)
    assert_includes stdout, 'trips_staging has 2 rows'
    assert_equal live_trips, Trip.count

    Rake::Task.tasks.each(&:reenable)
    ENV['FORCE'] = '1'
    run_import
    assert_equal 2, Trip.count
  end

  test 'import:rollback restores the data replaced by the last import' do
    live_trips = Trip.count
    ENV['FORCE'] = '1'
    run_import
    assert_equal 2, Trip.count

    capture_io { Rake::Task['import:rollback'].invoke }

    assert_equal live_trips, Trip.count
    assert_not table_exists?('trips_old')
  end

  private

  def build_feed(overrides = {})
    FileUtils.rm_f(@zip)
    Zip::File.open(@zip, create: true) do |zip|
      Dir[file_fixture('gtfs').join('*.txt')].each do |f|
        name = File.basename(f)
        if overrides.key?(name)
          zip.get_output_stream(name) { |io| io.write(overrides[name]) }
        else
          zip.add(name, f)
        end
      end
    end
  end

  def run_import(expect_exit: nil)
    stdout, = capture_io do
      if expect_exit
        error = assert_raises(SystemExit) { Rake::Task['import:all'].invoke }
        assert_equal expect_exit, error.status
      else
        Rake::Task['import:all'].invoke
      end
    end
    stdout
  end

  def table_exists?(name)
    ActiveRecord::Base.connection.table_exists?(name)
  end

  def select_values(sql)
    ActiveRecord::Base.connection.select_values(sql)
  end
end
