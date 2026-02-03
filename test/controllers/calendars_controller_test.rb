# frozen_string_literal: true

require 'test_helper'

class CalendarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calendar = calendars(:Calendar1).service_gid
  end

  test 'should get index' do
    get calendars_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'FULLW', json_response['data'][0]['service_gid']
    assert_equal true, json_response['data'][0]['monday']
    assert_equal '2007-01-01', json_response['data'][0]['start_date']
    assert_equal '2050-12-31', json_response['data'][0]['end_date']
  end

  test 'should show calendar' do
    get calendar_url(@calendar), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'FULLW', json_response['service_gid']
    assert_equal true, json_response['monday']
    assert_equal '2007-01-01', json_response['start_date']
    assert_equal '2050-12-31', json_response['end_date']
  end

  test 'should show calendar trips' do
    get calendar_trips_url(@calendar), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 7, json_response['total']
    assert_equal 7, json_response['data'].length
    assert_equal 'AB', json_response['data'][0]['route_gid']
    assert_equal 'FULLW', json_response['data'][0]['service_gid']
    assert_equal 'AB1', json_response['data'][0]['trip_gid']
    assert_equal 'to Bullfrog', json_response['data'][0]['trip_headsign']
    assert_equal '1', json_response['data'][0]['block_gid']
    assert_equal 'A_shp', json_response['data'][0]['shape_gid']
    assert_equal 2, json_response['data'][0]['stop_times'].length
    assert_equal '08:00:00', json_response['data'][0]['stop_times'][0]['arrival_time']
    assert_equal '08:00:00', json_response['data'][0]['stop_times'][0]['departure_time']
    assert_equal 'BEATTY_AIRPORT', json_response['data'][0]['stop_times'][0]['stop_gid']
    assert_equal 1, json_response['data'][0]['stop_times'][0]['stop_sequence']
    assert_equal 'A_shp', json_response['data'][0]['shape']['shape_gid']
    assert_equal 3, json_response['data'][0]['shape']['points'].length
  end

  test 'should show calendar calendar_dates' do
    get calendar_calendar_dates_url(@calendar), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'FULLW', json_response['data'][0]['service_gid']
    assert_equal '2007-06-04', json_response['data'][0]['date']
    assert_equal '2', json_response['data'][0]['exception_type']
  end
end
