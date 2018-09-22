require 'test_helper'

class TripsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trip = trips(:Trip_1)
  end

  test "should get index" do
    get trips_url, as: :json
    assert_response :success
  end

  test "should show trip" do
    get trip_url(@trip), as: :json
    assert_response :success
  end
end
