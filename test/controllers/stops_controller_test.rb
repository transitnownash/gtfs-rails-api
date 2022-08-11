# frozen_string_literal: true

require 'test_helper'

class StopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stop = stops(:Stop1).stop_gid
  end

  test 'should get index' do
    get stops_url, as: :json
    json_response = JSON.parse(response.body)
    assert_equal 9, json_response['total']
    assert_equal 'FUR_CREEK_RES', json_response['data'][0]['stop_gid']
    assert_response :success
  end

  test 'should show stop' do
    get stop_url(@stop), as: :json
    json_response = JSON.parse(response.body)
    assert_equal 'FUR_CREEK_RES', json_response['stop_gid']
    assert_equal [], json_response['child_stops']
    assert_nil json_response['parent_station']
    assert_response :success
  end

  test 'should show stop stop times' do
    get stop_stop_times_url(@stop), as: :json
    json_response = JSON.parse(response.body)
    assert_equal 2, json_response['total']
    assert_equal 'BFC1', json_response['data'][0]['trip_gid']
    assert_response :success
  end

  test 'should get nearby stop' do
    get stops_nearby_url({ longitude: -117.133, latitude: 36.425 }), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response['total']
    assert_equal 'FUR_CREEK_RES', json_response['data'][0]['stop_gid']
    assert_equal '36.425288', json_response['data'][0]['stop_lat']
    assert_equal '-117.133162', json_response['data'][0]['stop_lon']
  end

  test 'should get nearby stops with a wider radius' do
    get stops_nearby_url({ longitude: -117.133, latitude: 36.425, radius: 25_000 }), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response['total']
    assert_equal 'FUR_CREEK_RES', json_response['data'][0]['stop_gid']
    assert_equal '36.425288', json_response['data'][0]['stop_lat']
    assert_equal '-117.133162', json_response['data'][0]['stop_lon']
  end

  test 'should show stop trips' do
    get stop_trips_url(@stop), as: :json
    assert_response :success
  end

  test 'should show stop routes' do
    get stop_routes_url(@stop), as: :json
    assert_response :success
  end
end
