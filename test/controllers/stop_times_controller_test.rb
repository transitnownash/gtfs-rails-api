# frozen_string_literal: true

require 'test_helper'

class StopTimesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stop_times = stop_times(:StopTime1).stop_gid
  end

  test 'should get index' do
    get stop_times_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 28, json_response['total']
    assert_equal 28, json_response['data'].length
    assert_equal 'STBA', json_response['data'][0]['trip_gid']
    assert_equal '2000-01-01 06:00:00', json_response['data'][0]['arrival_time']
    assert_equal '2000-01-01 06:00:00', json_response['data'][0]['departure_time']
    assert_equal 'STAGECOACH', json_response['data'][0]['stop_gid']
    assert_equal 1, json_response['data'][0]['stop_sequence']
  end
end
