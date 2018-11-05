require 'test_helper'

class RealtimeControllerTest < ActionDispatch::IntegrationTest
  test "should get alerts" do
    get realtime_alerts_url
    # TODO: Set up mocks for realtime endpoints
    assert_response :success
  end

  test "should get vehicle_positions" do
    get realtime_vehicle_positions_url
    # TODO: Set up mocks for realtime endpoints
    assert_response :success
  end

  test "should get trip_updates" do
    get realtime_trip_updates_url
    # TODO: Set up mocks for realtime endpoints
    assert_response :success
  end
end
