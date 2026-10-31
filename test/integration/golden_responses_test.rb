# frozen_string_literal: true

require 'test_helper'

# Byte-for-byte snapshots of API responses. Regenerate with UPDATE_GOLDEN=1.
class GoldenResponsesTest < ActionDispatch::IntegrationTest
  GOLDEN_DIR = Rails.root.join('test/fixtures/files/golden')
  DATE = '2026-10-30'

  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    travel_to Time.zone.parse("#{DATE} 12:00:00")
    stub_feeds(alerts: 'alerts.pb', trip_updates: 'trip_updates.pb', vehicle_positions: 'vehicle_positions.pb')
  end

  teardown do
    travel_back
    Rails.cache = @original_cache
  end

  {
    'realtime_alerts' => '/realtime/alerts.json',
    'realtime_trip_updates' => '/realtime/trip_updates.json',
    'realtime_vehicle_positions' => '/realtime/vehicle_positions.json',
    'healthcheck' => '/healthcheck.json',
    'routes' => "/routes.json?date=#{DATE}",
    'route_trips' => "/routes/BFC/trips.json?date=#{DATE}",
    'route_shapes' => "/routes/BFC/shapes.json?date=#{DATE}",
    'route_stops' => "/routes/BFC/stops.json?date=#{DATE}",
    'route_by_short_name' => '/routes/20.json',
    'stop' => '/stops/FUR_CREEK_RES.json',
    'stop_next' => "/stops/FUR_CREEK_RES/next.json?time=09:00:00&date=#{DATE}",
    'stop_next_midnight' => "/stops/BULLFROG/next.json?time=01:00:00&date=#{DATE}",
    'stop_trips' => "/stops/FUR_CREEK_RES/trips.json?date=#{DATE}",
    'stop_trips_all' => '/stops/FUR_CREEK_RES/trips.json',
    'stop_stop_times' => '/stops/FUR_CREEK_RES/stop_times.json',
    'stop_routes' => '/stops/FUR_CREEK_RES/routes.json',
    'stop_times' => '/stop_times.json',
    'trips' => "/trips.json?date=#{DATE}",
    'trip' => '/trips/BFC1.json',
    'trip_stop_times' => '/trips/BFC1/stop_times.json',
    'trip_shape' => '/trips/BFC1/shape.json',
    'trip_block' => '/trips/BFC1/block.json',
    'calendar_trips' => '/calendars/FULLW/trips.json',
    'calendar_calendar_dates' => '/calendars/FULLW/calendar_dates.json'
  }.each do |name, path|
    test "golden #{name}" do
      # Second request is served from cache and must match too
      2.times do
        get path
        assert_golden name
      end
    end
  end

  test 'golden stop_next with matching realtime data' do
    stub_feeds(alerts: 'next_alerts.pb', trip_updates: 'next_trip_updates.pb',
               vehicle_positions: 'next_vehicle_positions.pb')
    get "/stops/FUR_CREEK_RES/next.json?time=09:00:00&date=#{DATE}"
    assert_golden 'stop_next_realtime'
  end

  test 'golden realtime endpoints with matching realtime data' do
    stub_feeds(alerts: 'next_alerts.pb', trip_updates: 'next_trip_updates.pb',
               vehicle_positions: 'next_vehicle_positions.pb')
    %w[alerts trip_updates vehicle_positions].each do |feed|
      get "/realtime/#{feed}.json"
      assert_golden "realtime_#{feed}_small"
    end
  end

  private

  def stub_feeds(files)
    files.each do |feed, file|
      stub_request(:get, "http://example.com/realtime/#{feed}.pb")
        .to_return(body: Rails.root.join('test/fixtures/files', file).binread, status: 200)
    end
  end

  # Fixture timestamps are set at load time, so mask them.
  def normalized_body
    "#{response.status}\n#{response.body.gsub(/"(created_at|updated_at)":"[^"]*"/, '"\1":"T"')}"
  end

  def assert_golden(name)
    path = GOLDEN_DIR.join("#{name}.json")
    if ENV['UPDATE_GOLDEN']
      FileUtils.mkdir_p(GOLDEN_DIR)
      File.write(path, normalized_body)
    end
    assert_equal File.read(path), normalized_body, "#{name} response changed"
  end
end
