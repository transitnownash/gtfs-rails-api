require 'test_helper'

class TripsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trip = trips(:Trip_1).trip_gid
  end

  test "should get index" do
    get trips_url, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 7, json_response['total']
    assert_equal 'AB', json_response['data'][0]['route_gid']
  end

  test "should show trip" do
    get trip_url(@trip), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'AB', json_response['route_gid']
    assert_equal 'AB1', json_response['trip_gid']
    assert_equal 2, json_response['stop_times'].length
  end

  test "should show trip shape" do
    get trip_shape_url(@trip), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 178229, json_response['id']
    assert_equal 'A_shp', json_response['shape_gid']
    assert_equal 3, json_response['points'].length
  end

  test "should show trip block" do
    get trip_block_url(@trip), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'AB', json_response[0]['route_gid']
    assert_equal 'AB1', json_response[0]['trip_gid']
  end

  test "should show trip stop times" do
    get trip_stop_times_url(@trip), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 2, json_response['total']
    assert_equal 'AB1', json_response['data'][0]['trip_gid']
  end
end
