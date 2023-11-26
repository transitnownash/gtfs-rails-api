# frozen_string_literal: true

require 'test_helper'

class FeedInfosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @feed_info = feed_infos(:FeedInfo1).id
  end

  test 'should get index' do
    get feed_infos_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 1, json_response['total']
    assert_equal 1, json_response['data'].length
    assert_equal 'Google Sample Data', json_response['data'][0]['feed_publisher_name']
    assert_equal 'https://google.com', json_response['data'][0]['feed_publisher_url']
    assert_equal 'en', json_response['data'][0]['feed_lang']
    assert_equal '2006-07-01', json_response['data'][0]['feed_start_date']
    assert_equal '2006-07-31', json_response['data'][0]['feed_end_date']
    assert_equal '1.0', json_response['data'][0]['feed_version']
  end

  test 'should show feed_info' do
    get feed_info_url(@feed_info), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'Google Sample Data', json_response['feed_publisher_name']
    assert_equal 'https://google.com', json_response['feed_publisher_url']
    assert_equal 'en', json_response['feed_lang']
    assert_equal '2006-07-01', json_response['feed_start_date']
    assert_equal '2006-07-31', json_response['feed_end_date']
    assert_equal '1.0', json_response['feed_version']
  end
end
