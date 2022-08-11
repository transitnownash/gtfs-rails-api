# frozen_string_literal: true

require 'test_helper'

class AgenciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @agency = agencies(:Agency1).agency_gid
  end

  test 'should get index' do
    get agencies_url, as: :json
    assert_response :success
  end

  test 'should show agency' do
    get agency_url(@agency), as: :json
    assert_response :success
  end
end
