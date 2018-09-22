require 'test_helper'

class AgenciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @agency = agencies(:Agency_1)
  end

  test "should get index" do
    get agencies_url, as: :json
    assert_response :success
  end

  test "should show agency" do
    get agency_url(@agency), as: :json
    assert_response :success
  end
end
