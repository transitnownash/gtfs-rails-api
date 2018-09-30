require 'test_helper'

class FeedInfosControllerTest < ActionDispatch::IntegrationTest
  test "should show feed_info" do
    get feed_info_url, as: :json
    assert_response :success
  end
end
