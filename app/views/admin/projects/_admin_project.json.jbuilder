json.extract! project, :id, :title, :description, :github_url, :live_url, :featured_image, :tags, :created_at,
              :updated_at
json.url project_url(project, format: :json)
