require "application_system_test_case"

class Admin::BlogPostsTest < ApplicationSystemTestCase
  setup do
    @admin_blog_post = admin_blog_posts(:one)
  end

  test "visiting the index" do
    visit admin_blog_posts_url
    assert_selector "h1", text: "Blog posts"
  end

  test "should create blog post" do
    visit admin_blog_posts_url
    click_on "New blog post"

    fill_in "Body", with: @admin_blog_post.body
    fill_in "Published at", with: @admin_blog_post.published_at
    fill_in "Slug", with: @admin_blog_post.slug
    fill_in "Title", with: @admin_blog_post.title
    click_on "Create Blog post"

    assert_text "Blog post was successfully created"
    click_on "Back"
  end

  test "should update Blog post" do
    visit admin_blog_post_url(@admin_blog_post)
    click_on "Edit this blog post", match: :first

    fill_in "Body", with: @admin_blog_post.body
    fill_in "Published at", with: @admin_blog_post.published_at
    fill_in "Slug", with: @admin_blog_post.slug
    fill_in "Title", with: @admin_blog_post.title
    click_on "Update Blog post"

    assert_text "Blog post was successfully updated"
    click_on "Back"
  end

  test "should destroy Blog post" do
    visit admin_blog_post_url(@admin_blog_post)
    click_on "Destroy this blog post", match: :first

    assert_text "Blog post was successfully destroyed"
  end
end
