# frozen_string_literal: true

require 'test_helper'

class TransfersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transfer = transfers(:Transfer1)
  end

  test 'should get index' do
    get transfers_url, as: :json
    assert_response :success
  end

  test 'should show transfer' do
    get transfer_url(@transfer), as: :json
    assert_response :success
  end
end
