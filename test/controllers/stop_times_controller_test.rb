# frozen_string_literal: true

require 'test_helper'

class StopTimesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stop_time = stop_times(:StopTime1).id
  end

  test 'should get index' do
    get stop_times_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 35, json_response['total']
    assert_equal 35, json_response['data'].length
    # Verify the data includes expected stop times
    assert json_response['data'].any? { |st| st['trip_gid'] == 'STBA' }
    assert json_response['data'].any? { |st| st['trip_gid'] == 'BFC1' }
  end

  test 'should show stop_time' do
    get stop_time_url(@stop_time), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'STBA', json_response['trip_gid']
    assert_equal '06:00:00', json_response['arrival_time']
    assert_equal '06:00:00', json_response['departure_time']
    assert_equal 'STAGECOACH', json_response['stop_gid']
    assert_equal 1, json_response['stop_sequence']
  end
end
