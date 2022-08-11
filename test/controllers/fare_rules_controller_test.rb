# frozen_string_literal: true

require 'test_helper'

class FareRulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fare_rule = fare_rules(:FareRule1)
  end

  test 'should get index' do
    get fare_rules_url, as: :json
    assert_response :success
  end

  test 'should show fare_rule' do
    get fare_rule_url(@fare_rule), as: :json
    assert_response :success
  end
end
