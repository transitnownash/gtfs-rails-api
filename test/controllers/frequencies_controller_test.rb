# frozen_string_literal: true

require 'test_helper'

class FrequenciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @frequency = frequencies(:Frequency_1)
  end

  test 'should get index' do
    get frequencies_url, as: :json
    assert_response :success
  end

  test 'should show frequency' do
    get frequency_url(@frequency), as: :json
    assert_response :success
  end
end
