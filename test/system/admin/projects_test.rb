require "application_system_test_case"

class Admin::ProjectsTest < ApplicationSystemTestCase
  setup do
    @admin_project = admin_projects(:one)
  end

  test "visiting the index" do
    visit admin_projects_url
    assert_selector "h1", text: "Projects"
  end

  test "should create project" do
    visit admin_projects_url
    click_on "New project"

    fill_in "Description", with: @admin_project.description
    fill_in "Featured image", with: @admin_project.featured_image
    fill_in "Github url", with: @admin_project.github_url
    fill_in "Live url", with: @admin_project.live_url
    fill_in "Tags", with: @admin_project.tags
    fill_in "Title", with: @admin_project.title
    click_on "Create Project"

    assert_text "Project was successfully created"
    click_on "Back"
  end

  test "should update Project" do
    visit admin_project_url(@admin_project)
    click_on "Edit this project", match: :first

    fill_in "Description", with: @admin_project.description
    fill_in "Featured image", with: @admin_project.featured_image
    fill_in "Github url", with: @admin_project.github_url
    fill_in "Live url", with: @admin_project.live_url
    fill_in "Tags", with: @admin_project.tags
    fill_in "Title", with: @admin_project.title
    click_on "Update Project"

    assert_text "Project was successfully updated"
    click_on "Back"
  end

  test "should destroy Project" do
    visit admin_project_url(@admin_project)
    click_on "Destroy this project", match: :first

    assert_text "Project was successfully destroyed"
  end
end
