require 'test_helper'

class FeedInfosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @feed_info = feed_infos(:FeedInfo_1)
  end

  test "should get index" do
    get feed_infos_url, as: :json
    assert_response :success
  end

  test "should show feed_info" do
    get feed_info_url(@feed_info), as: :json
    assert_response :success
  end
end
