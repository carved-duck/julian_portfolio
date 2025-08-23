Rails.application.routes.draw do
  # For the Public site
  resources :projects, only: %i[index show]
  resources :photos, only: %i[index show]
  resources :blog_posts, only: %i[index show], path: "blog"
  resources :events, only: %i[index show] do
    resources :attendees, only: %i[new create] do
      collection do
        post :confirm_pending
      end
    end
  end
  post 'contact', to: 'pages#contact'

  # SEO Routes
  get 'sitemap.xml', to: 'pages#sitemap', defaults: { format: 'xml' }

  # Admin routes
  namespace :admin do
    root to: "dashboard#index"
    resources :projects
    resources :photos do
      member do
        patch :feature
        patch :unfeature
      end
      collection do
        get :bulk_upload
        post :bulk_create
        post :upload_single, action: :upload_single_file
        delete 'categories/:category_name', action: :destroy_category, as: :destroy_category
      end
    end
    resources :blog_posts
    resources :events do
      resources :attendees, only: [:show, :edit, :update, :destroy]
    end
  end
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  #
end
