# frozen_string_literal: true

require 'test_helper'

class FareRulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fare_rule = fare_rules(:FareRule1).id
  end

  test 'should get index' do
    get fare_rules_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 4, json_response['total']
    assert_equal 4, json_response['data'].length
    assert_equal 'p', json_response['data'][0]['fare_gid']
    assert_equal 'AB', json_response['data'][0]['route_gid']
  end

  test 'should show fare_rule' do
    get fare_rule_url(@fare_rule), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'p', json_response['fare_gid']
    assert_equal 'AB', json_response['route_gid']
  end
end
