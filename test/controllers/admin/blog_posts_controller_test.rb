require "test_helper"

class Admin::BlogPostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_blog_post = admin_blog_posts(:one)
  end

  test "should get index" do
    get admin_blog_posts_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_blog_post_url
    assert_response :success
  end

  test "should create admin_blog_post" do
    assert_difference("Admin::BlogPost.count") do
      post admin_blog_posts_url, params: { admin_blog_post: { body: @admin_blog_post.body, published_at: @admin_blog_post.published_at, slug: @admin_blog_post.slug, title: @admin_blog_post.title } }
    end

    assert_redirected_to admin_blog_post_url(Admin::BlogPost.last)
  end

  test "should show admin_blog_post" do
    get admin_blog_post_url(@admin_blog_post)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_blog_post_url(@admin_blog_post)
    assert_response :success
  end

  test "should update admin_blog_post" do
    patch admin_blog_post_url(@admin_blog_post), params: { admin_blog_post: { body: @admin_blog_post.body, published_at: @admin_blog_post.published_at, slug: @admin_blog_post.slug, title: @admin_blog_post.title } }
    assert_redirected_to admin_blog_post_url(@admin_blog_post)
  end

  test "should destroy admin_blog_post" do
    assert_difference("Admin::BlogPost.count", -1) do
      delete admin_blog_post_url(@admin_blog_post)
    end

    assert_redirected_to admin_blog_posts_url
  end
end
