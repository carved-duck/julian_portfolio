class PhotosController < ApplicationController
  def index
    @categories = Photo.categories

    # Show first category by default, or selected category
    selected_category = params[:category].presence || @categories.first
    @photos = selected_category ? Photo.by_category(selected_category).recent : Photo.none
    @selected_category = selected_category
  end

  def show
    @photo = Photo.find(params[:id])

    # Get photos in same category for navigation
    @category_photos = Photo.by_category(@photo.category).recent
    @current_index = @category_photos.find_index(@photo)

    # Find next and previous photos
    @next_photo = @category_photos[@current_index + 1] if @current_index && @current_index < @category_photos.length - 1
    @prev_photo = @category_photos[@current_index - 1] if @current_index && @current_index > 0
  end
end
