require 'test_helper'

class CalendarDatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calendar_date = calendar_dates(:CalendarDate_1)
  end

  test "should get index" do
    get calendar_dates_url, as: :json
    assert_response :success
  end

  test "should show calendar_date" do
    get calendar_date_url(@calendar_date), as: :json
    assert_response :success
  end
end
