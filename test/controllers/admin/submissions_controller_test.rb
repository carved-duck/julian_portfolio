require "test_helper"

class Admin::SubmissionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_submissions_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_submissions_show_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_submissions_destroy_url
    assert_response :success
  end
end
