# frozen_string_literal: true

require 'test_helper'

class FrequenciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @frequency = frequencies(:Frequency1)
  end

  test 'should get index' do
    get frequencies_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 11, json_response['total']
    assert_equal 11, json_response['data'].length
    assert_equal 'STBA', json_response['data'][0]['trip_gid']
    assert_equal '06:00:00', json_response['data'][0]['start_time']
    assert_equal '22:00:00', json_response['data'][0]['end_time']
    assert_equal 1800, json_response['data'][0]['headway_secs']
  end

  test 'should show frequency' do
    get frequency_url(@frequency), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'STBA', json_response['trip_gid']
    assert_equal '06:00:00', json_response['start_time']
    assert_equal '22:00:00', json_response['end_time']
    assert_equal 1800, json_response['headway_secs']
  end
end
