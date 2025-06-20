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
  end
end
