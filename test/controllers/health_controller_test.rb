# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class HealthControllerTest < ActionDispatch::IntegrationTest
  setup do
    stub_request(:get, 'http://example.com/realtime/alerts.pb')
      .to_return(body: File.new('./test/fixtures/files/alerts.pb'), status: 200)
  end

  test 'should report healthy services' do
    get healthcheck_url

    assert_response :success

    json_response = response.parsed_body
    assert_equal 'ok', json_response['status']
    assert_equal [
      { 'name' => 'database', 'status' => 'ok' },
      { 'name' => 'realtime_alerts', 'status' => 'ok' },
      { 'name' => 'static_schedule_data', 'status' => 'ok' }
    ], json_response['services']
  end

  test 'should report failing realtime alerts service' do
    stub_request(:get, 'http://example.com/realtime/alerts.pb')
      .to_return(status: 500, body: 'upstream failure')

    get healthcheck_url

    assert_response :service_unavailable

    json_response = response.parsed_body
    assert_equal 'failing', json_response['status']
    assert_equal 'ok', json_response['services'][0]['status']
    assert_equal 'failing', json_response['services'][1]['status']
    assert_equal 'Realtime feed returned HTTP 500', json_response['services'][1]['error']
    assert_equal 'ok', json_response['services'][2]['status']
  end
end
