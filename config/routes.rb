Rails.application.routes.draw do
  # For the Public site
  resources :projects, only: %i[index show]
  resources :photos, only: %i[index show]
  resources :blog_posts, only: %i[index show], path: "blog"
  resources :submissions, only: %i[new create]
  # Admin die
  namespace :admin do
    root to: "dashboard#index"
    resources :projects
    resources :photos
    resources :blog_posts
    resources :submissions, only: [:index, :show, :destroy]
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
