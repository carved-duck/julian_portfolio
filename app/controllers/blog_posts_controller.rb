class BlogPostsController < ApplicationController
  def index
    @blog_posts = BlogPost.published.recent
  end

  def show
    @blog_post = BlogPost.find_by!(slug: params[:id]) || BlogPost.find(params[:id])
  end
end
