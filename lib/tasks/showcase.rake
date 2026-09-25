namespace :showcase do
  desc "Create or update the dev-work cards and their images from db/showcase/projects.yml (FORCE_IMAGES=1 re-uploads)"
  task load: :environment do
    ShowcaseLoader.new(force_images: ENV["FORCE_IMAGES"].present?).call
  end
end
