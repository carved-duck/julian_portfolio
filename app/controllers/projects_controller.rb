class ProjectsController < ApplicationController
  def index
    # Eager-load every image a card can show so each card doesn't query its own (N+1).
    @projects = Project.by_start
                       .with_attached_featured_image.with_attached_screenshots.with_attached_icon.to_a
    @hero = @projects.find { |p| p.title.to_s.strip.casecmp?(Project::HERO_TITLE) } || @projects.first
    @eras = Project::SECTIONS.index_with { |section| @projects.select { |p| p.section == section && p != @hero } }
                             .reject { |_, projects| projects.empty? }
  end

  def show
    @project = Project.find(params[:id])
    # "More projects": the three newest others.
    @more_projects = Project.where.not(id: @project.id).by_start.limit(3)
                            .with_attached_featured_image.with_attached_screenshots.with_attached_icon
  end
end
