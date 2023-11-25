# frozen_string_literal: true

require 'test_helper'

class AgenciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @agency = agencies(:Agency1).agency_gid
  end

  test 'should get index' do
    get agencies_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 1, json_response['total']
    assert_equal 1, json_response['data'].length
    assert_equal 'Demo Transit Authority', json_response['data'][0]['agency_name']
    assert_equal 'http://google.com', json_response['data'][0]['agency_url']
    assert_equal 'America/Los_Angeles', json_response['data'][0]['agency_timezone']
  end

  test 'should show agency' do
    get agency_url(@agency), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'Demo Transit Authority', json_response['agency_name']
    assert_equal 'http://google.com', json_response['agency_url']
    assert_equal 'America/Los_Angeles', json_response['agency_timezone']
  end
end
