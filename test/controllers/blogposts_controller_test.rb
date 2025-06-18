require "test_helper"

class BlogpostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get blogposts_index_url
    assert_response :success
  end

  test "should get show" do
    get blogposts_show_url
    assert_response :success
  end
end
