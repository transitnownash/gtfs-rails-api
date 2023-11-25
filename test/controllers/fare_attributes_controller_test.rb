# frozen_string_literal: true

require 'test_helper'

class FareAttributesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fare_attribute = fare_attributes(:FareAttribute1)
  end

  test 'should get index' do
    get fare_attributes_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 2, json_response['total']
    assert_equal 2, json_response['data'].length
    assert_equal 'p', json_response['data'][0]['fare_gid']
    assert_equal 1, json_response['data'][0]['price']
    assert_equal 'USD', json_response['data'][0]['currency_type']
    assert_equal '0', json_response['data'][0]['payment_method']
  end

  test 'should show fare_attribute' do
    get fare_attribute_url(@fare_attribute), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'p', json_response['fare_gid']
    assert_equal 1, json_response['price']
    assert_equal 'USD', json_response['currency_type']
    assert_equal '0', json_response['payment_method']
  end
end
