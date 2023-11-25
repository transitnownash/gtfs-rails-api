# frozen_string_literal: true

require 'test_helper'

class RoutesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @route = routes(:Route1).route_gid
  end

  test 'should get index' do
    get routes_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 5, json_response['total']
    assert_equal 5, json_response['data'].length
    assert_equal 'AB', json_response['data'][0]['route_gid']
    assert_equal 'DTA', json_response['data'][0]['agency_gid']
    assert_equal '10', json_response['data'][0]['route_short_name']
    assert_equal 'Airport - Bullfrog', json_response['data'][0]['route_long_name']
    assert_equal '3', json_response['data'][0]['route_type']
  end

  test 'should show route' do
    get route_url(@route), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'AB', json_response['route_gid']
    assert_equal 'DTA', json_response['agency_gid']
    assert_equal '10', json_response['route_short_name']
    assert_equal 'Airport - Bullfrog', json_response['route_long_name']
    assert_equal '3', json_response['route_type']
  end

  test 'should get route trips' do
    get route_trips_url(@route), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 2, json_response['total']
    assert_equal 2, json_response['data'].length
    assert_equal 'AB', json_response['data'][0]['route_gid']
    assert_equal 'FULLW', json_response['data'][0]['service_gid']
    assert_equal 'AB1', json_response['data'][0]['trip_gid']
    assert_equal 'to Bullfrog', json_response['data'][0]['trip_headsign']
    assert_equal '0', json_response['data'][0]['direction_id']
    assert_equal '1', json_response['data'][0]['block_gid']
  end

  test 'should get route shapes' do
    get route_shapes_url(@route), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 1, json_response['total']
    assert_equal 1, json_response['data'].length
    assert_equal 'A_shp', json_response['data'][0]['shape_gid']
    assert_equal 3, json_response['data'][0]['points'].length
    assert_equal 37.61956, json_response['data'][0]['points'][0]['shape_pt_lat']
    assert_equal(-122.48161, json_response['data'][0]['points'][0]['shape_pt_lon'])
    assert_equal 1, json_response['data'][0]['points'][0]['shape_pt_sequence']
    assert_equal 0.0, json_response['data'][0]['points'][0]['shape_dist_traveled']
  end

  test 'should get route stops' do
    get route_stops_url(@route), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 2, json_response['total']
    assert_equal 2, json_response['data'].length
  end
end
