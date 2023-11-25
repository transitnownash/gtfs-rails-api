# frozen_string_literal: true

require 'test_helper'

class ShapesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @shape = shapes(:Shape1).shape_gid
  end

  test 'should get index' do
    get shapes_url, as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 1, json_response['total']
    assert_equal 1, json_response['data'].length
    assert_equal 'A_shp', json_response['data'][0]['shape_gid']
    assert_equal 3, json_response['data'][0]['points'].length
    assert_equal 37.61956, json_response['data'][0]['points'][0]['shape_pt_lat']
    assert_equal(-122.48161, json_response['data'][0]['points'][0]['shape_pt_lon'])
    assert_equal 1, json_response['data'][0]['points'][0]['shape_pt_sequence']
    assert_equal 0, json_response['data'][0]['points'][0]['shape_dist_traveled']
  end

  test 'should show shape' do
    get shape_url(@shape), as: :json
    assert_response :success
    json_response = response.parsed_body
    assert_equal 'A_shp', json_response['shape_gid']
    assert_equal 3, json_response['points'].length
    assert_equal 37.61956, json_response['points'][0]['shape_pt_lat']
    assert_equal(-122.48161, json_response['points'][0]['shape_pt_lon'])
    assert_equal 1, json_response['points'][0]['shape_pt_sequence']
    assert_equal 0, json_response['points'][0]['shape_dist_traveled']
  end
end
