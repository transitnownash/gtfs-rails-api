# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'

# Force test-specific realtime endpoints to match WebMock stubs
# Use explicit assignment to override any values coming from `.env`
ENV['GTFS_REALTIME_ALERTS_URL'] = 'http://example.com/realtime/alerts.pb'
ENV['GTFS_REALTIME_TRIP_UPDATES_URL'] = 'http://example.com/realtime/trip_updates.pb'
ENV['GTFS_REALTIME_VEHICLE_POSITIONS_URL'] = 'http://example.com/realtime/vehicle_positions.pb'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
