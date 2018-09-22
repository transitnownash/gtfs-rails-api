require 'test_helper'

class CalendarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calendar = calendars(:Calendar_1)
  end

  test "should get index" do
    get calendars_url, as: :json
    assert_response :success
  end

  test "should show calendar" do
    get calendar_url(@calendar), as: :json
    assert_response :success
  end
end
