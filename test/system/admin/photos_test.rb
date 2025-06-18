require "application_system_test_case"

class Admin::PhotosTest < ApplicationSystemTestCase
  setup do
    @admin_photo = admin_photos(:one)
  end

  test "visiting the index" do
    visit admin_photos_url
    assert_selector "h1", text: "Photos"
  end

  test "should create photo" do
    visit admin_photos_url
    click_on "New photo"

    fill_in "Category", with: @admin_photo.category
    click_on "Create Photo"

    assert_text "Photo was successfully created"
    click_on "Back"
  end

  test "should update Photo" do
    visit admin_photo_url(@admin_photo)
    click_on "Edit this photo", match: :first

    fill_in "Category", with: @admin_photo.category
    click_on "Update Photo"

    assert_text "Photo was successfully updated"
    click_on "Back"
  end

  test "should destroy Photo" do
    visit admin_photo_url(@admin_photo)
    click_on "Destroy this photo", match: :first

    assert_text "Photo was successfully destroyed"
  end
end
