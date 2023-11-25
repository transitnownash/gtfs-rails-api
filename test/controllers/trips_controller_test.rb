# frozen_string_literal: true

require 'test_helper'

class TripsControllerTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.zone.local(2022, 8, 4, 12, 0, 0)
    @trip = trips(:Trip1).trip_gid
  end

  test 'should get index' do
    get trips_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 7, json_response['total']
    assert_equal 7, json_response['data'].length
    assert_equal 'AB', json_response['data'][0]['route_gid']
    assert_equal 'FULLW', json_response['data'][0]['service_gid']
    assert_equal 'AB1', json_response['data'][0]['trip_gid']
    assert_equal 'to Bullfrog', json_response['data'][0]['trip_headsign']
    assert_equal '0', json_response['data'][0]['direction_id']
    assert_equal '1', json_response['data'][0]['block_gid']
  end

  test 'should show trip' do
    get trip_url(@trip), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'AB', json_response['route_gid']
    assert_equal 'AB1', json_response['trip_gid']
    assert_equal 2, json_response['stop_times'].length
    assert_equal 'AB', json_response['route_gid']
    assert_equal 'FULLW', json_response['service_gid']
    assert_equal 'AB1', json_response['trip_gid']
    assert_equal 'to Bullfrog', json_response['trip_headsign']
    assert_equal '0', json_response['direction_id']
    assert_equal '1', json_response['block_gid']
  end

  test 'should show trip shape' do
    get trip_shape_url(@trip), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'A_shp', json_response['shape_gid']
    assert_equal 3, json_response['points'].length
    assert_equal 37.61956, json_response['points'][0]['shape_pt_lat']
    assert_equal(-122.48161, json_response['points'][0]['shape_pt_lon'])
    assert_equal 1, json_response['points'][0]['shape_pt_sequence']
    assert_equal 0, json_response['points'][0]['shape_dist_traveled']
  end

  test 'should show trip block' do
    get trip_block_url(@trip), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'AB', json_response[0]['route_gid']
    assert_equal 'AB1', json_response[0]['trip_gid']
  end

  test 'should show trip stop times' do
    get trip_stop_times_url(@trip), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 2, json_response['total']
    assert_equal 'AB1', json_response['data'][0]['trip_gid']
  end
end
