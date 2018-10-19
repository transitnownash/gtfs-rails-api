require 'test_helper'

class StopTimesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stop_times = stop_times(:StopTime_1).stop_gid
  end

  test "should get index" do
    get stop_times_url, as: :json
    assert_response :success
  end

  test "should show stop stop_times" do
    get stop_time_url(@stop_times), as: :json
    assert_response :success
  end
end
