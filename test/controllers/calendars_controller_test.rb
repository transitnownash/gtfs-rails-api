# frozen_string_literal: true

require 'test_helper'

class CalendarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calendar = calendars(:Calendar1).service_gid
  end

  test 'should get index' do
    get calendars_url, as: :json
    assert_response :success
  end

  test 'should show calendar' do
    get calendar_url(@calendar), as: :json
    assert_response :success
  end

  test 'should show calendar trips' do
    get calendar_trips_url(@calendar), as: :json
    assert_response :success
  end

  test 'should show calendar calendar_dates' do
    get calendar_calendar_dates_url(@calendar), as: :json
    assert_response :success
  end
end
