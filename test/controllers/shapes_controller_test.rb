require 'test_helper'

class ShapesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @shape = shapes(:Shape_1).shape_gid
  end

  test "should get index" do
    get shapes_url, as: :json
    assert_response :success
  end

  test "should show shape" do
    get shape_url(@shape), as: :json
    assert_response :success
  end
end
