class PhotosController < ApplicationController
  def index
    @photos = if params[:category].present?
        Photo.by_category(params[:category]).recent
      else
        Photo.recent
      end
      @categories = Photo.categories
  end

  def show
    @photo = Photo.find(params[:id])
  end
end
