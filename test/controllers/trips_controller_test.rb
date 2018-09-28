require 'test_helper'

class TripsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trip = trips(:Trip_1).trip_gid
  end

  test "should get index" do
    get trips_url, as: :json
    assert_response :success
  end

  test "should show trip" do
    get trip_url(@trip), as: :json
    assert_response :success
  end

  test "should show trip shape" do
    get trip_shape_url(@trip), as: :json
    assert_response :success
  end

  test "should show trip stop times" do
    get trip_stop_times_url(@trip), as: :json
    assert_response :success
  end
end
