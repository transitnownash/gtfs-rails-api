# frozen_string_literal: true

require 'test_helper'

class TransfersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transfer = transfers(:Transfer1)
  end

  test 'should get index' do
    get transfers_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 3, json_response['total']
    assert_equal 3, json_response['data'].length
    assert_equal 'S6', json_response['data'][0]['from_stop_gid']
    assert_equal 'S7', json_response['data'][0]['to_stop_gid']
    assert_equal '2', json_response['data'][0]['transfer_type']
    assert_equal 300, json_response['data'][0]['min_transfer_time']
  end

  test 'should show transfer' do
    get transfer_url(@transfer), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'S6', json_response['from_stop_gid']
    assert_equal 'S7', json_response['to_stop_gid']
    assert_equal '2', json_response['transfer_type']
    assert_equal 300, json_response['min_transfer_time']
  end
end
