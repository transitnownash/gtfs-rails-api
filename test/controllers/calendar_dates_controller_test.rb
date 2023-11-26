# frozen_string_literal: true

require 'test_helper'

class CalendarDatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calendar_date = calendar_dates(:CalendarDate1).service_gid
  end

  test 'should get index' do
    get calendar_dates_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'FULLW', json_response['data'][0]['service_gid']
    assert_equal '2007-06-04', json_response['data'][0]['date']
    assert_equal '2', json_response['data'][0]['exception_type']
  end

  test 'should show calendar_date' do
    get calendar_date_url(@calendar_date), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'FULLW', json_response['data'][0]['service_gid']
    assert_equal '2007-06-04', json_response['data'][0]['date']
    assert_equal '2', json_response['data'][0]['exception_type']
  end
end
