class ProjectsController < ApplicationController
  def index
    # Eager-load the attachment + blob so each card doesn't fire its own pair of
    # queries (N+1) for featured_image.attached? / .key in the view.
    @projects = Project.with_attached_featured_image
  end

  def show
    @project = Project.find(params[:id])
  end
end
