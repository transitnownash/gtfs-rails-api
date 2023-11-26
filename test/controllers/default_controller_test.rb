# frozen_string_literal: true

require 'test_helper'

class DefaultControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get root_url
    assert_response :success
    json_response = response.parsed_body
    assert_equal 41, json_response.length
    assert_equal '/', json_response[0]
    assert_equal '/agencies.json', json_response[1]
    assert_equal '/agencies/:agency_gid.json', json_response[2]
  end
end
