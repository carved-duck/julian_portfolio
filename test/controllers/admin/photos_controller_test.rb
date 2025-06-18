require "test_helper"

class Admin::PhotosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_photo = admin_photos(:one)
  end

  test "should get index" do
    get admin_photos_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_photo_url
    assert_response :success
  end

  test "should create admin_photo" do
    assert_difference("Admin::Photo.count") do
      post admin_photos_url, params: { admin_photo: { category: @admin_photo.category } }
    end

    assert_redirected_to admin_photo_url(Admin::Photo.last)
  end

  test "should show admin_photo" do
    get admin_photo_url(@admin_photo)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_photo_url(@admin_photo)
    assert_response :success
  end

  test "should update admin_photo" do
    patch admin_photo_url(@admin_photo), params: { admin_photo: { category: @admin_photo.category } }
    assert_redirected_to admin_photo_url(@admin_photo)
  end

  test "should destroy admin_photo" do
    assert_difference("Admin::Photo.count", -1) do
      delete admin_photo_url(@admin_photo)
    end

    assert_redirected_to admin_photos_url
  end
end
