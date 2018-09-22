require 'test_helper'

class StopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stop = stops(:Stop_1)
  end

  test "should get index" do
    get stops_url, as: :json
    assert_response :success
  end

  test "should show stop" do
    get stop_url(@stop), as: :json
    assert_response :success
  end
end
