# frozen_string_literal: true

require 'test_helper'

class FareAttributesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fare_attribute = fare_attributes(:FareAttribute1)
  end

  test 'should get index' do
    get fare_attributes_url, as: :json
    assert_response :success
  end

  test 'should show fare_attribute' do
    get fare_attribute_url(@fare_attribute), as: :json
    assert_response :success
  end
end
