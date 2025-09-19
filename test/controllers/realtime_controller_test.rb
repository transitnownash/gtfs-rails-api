# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class RealtimeControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Stub real Nashville endpoints for alerts, vehicle_positions, and trip_updates
    stub_request(:any, %r{transitdata.nashvillemta.org/TMGTFSRealTimeWebService/alert/alerts\.pb})
      .to_return(body: File.new('./test/fixtures/files/alerts.pb'), status: 200)
    stub_request(:any, %r{transitdata.nashvillemta.org/TMGTFSRealTimeWebService/vehicle/vehiclepositions\.pb})
      .to_return(body: File.new('./test/fixtures/files/vehicle_positions.pb'), status: 200)
    stub_request(:any, %r{transitdata.nashvillemta.org/TMGTFSRealTimeWebService/tripupdate/tripupdates\.pb})
      .to_return(body: File.new('./test/fixtures/files/trip_updates.pb'), status: 200)
    # Stub example.com endpoints for alerts, vehicle_positions, and trip_updates
    stub_request(:any, %r{example.com/realtime/alerts\.pb})
      .to_return(body: File.new('./test/fixtures/files/alerts.pb'), status: 200)
    stub_request(:any, %r{example.com/realtime/vehicle_positions\.pb})
      .to_return(body: File.new('./test/fixtures/files/vehicle_positions.pb'), status: 200)
    stub_request(:any, %r{example.com/realtime/trip_updates\.pb})
      .to_return(body: File.new('./test/fixtures/files/trip_updates.pb'), status: 200)
  end

  test 'should get alerts' do
    get realtime_alerts_url
    assert_response :success
    json_response = response.parsed_body
    assert_equal 12, json_response.length
    assert_equal JSON.parse(File.new('./test/fixtures/files/alerts.json').read), json_response[0]
  end

  test 'should get vehicle_positions' do
    get realtime_vehicle_positions_url
    assert_response :success
    json_response = response.parsed_body
    assert_equal 66, json_response.length
    assert_equal JSON.parse(File.new('./test/fixtures/files/vehicle_positions.json').read), json_response[0]
  end

  test 'should get trip_updates' do
    get realtime_trip_updates_url
    assert_response :success
    json_response = response.parsed_body
    assert_equal 105, json_response.length
    assert_equal JSON.parse(File.new('./test/fixtures/files/trip_updates.json').read), json_response[0]
  end
end
