# frozen_string_literal: true

require 'test_helper'

class RetailLocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retail_location = retail_locations(:RetailLocation1).location_code
  end

  test 'should get index' do
    get retail_locations_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 2, json_response['total']
    assert_equal 2, json_response['data'].length
    assert_equal '170', json_response['data'][1]['location_code']
    assert_equal 'CVS Pharmacy', json_response['data'][1]['name']
  end

  test 'should show retail_location' do
    get retail_location_url(@retail_location), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal '170', json_response['location_code']
    assert_equal 'CVS Pharmacy', json_response['name']
  end
end
