json.extract! admin_blog_post, :id, :title, :body, :published_at, :slug, :created_at, :updated_at
json.url admin_blog_post_url(admin_blog_post, format: :json)
