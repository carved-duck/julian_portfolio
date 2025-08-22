module Admin
  class ProjectsController < Admin::BaseController
    before_action :set_project, only: %i[show edit update destroy]
    # GET /admin/projects or /admin/projects.json
    def index
      @projects = Project.all
    end

    # GET /admin/projects/1 or /admin/projects/1.json
    def show
    end

    # GET /admin/projects/new
    def new
      @project = Project.new
    end

    # GET /admin/projects/1/edit
    def edit
    end

    # POST /admin/projects or /admin/projects.json
    def create
      @project = Project.new(project_params)
      respond_to do |format|
        if @project.save
          format.html { redirect_to admin_project_path(@project), notice: "Project was successfully created." }
          format.json { render :show, status: :created, location: @project }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/projects/1 or /admin/projects/1.json
    def update
      respond_to do |format|
        if @project.update(project_params)
          format.html { redirect_to admin_project_path(@project), notice: "Project was successfully updated." }
          format.json { render :show, status: :ok, location: @project }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /admin/projects/1 or /admin/projects/1.json
    def destroy
      @project.destroy!

      respond_to do |format|
        format.html do
          redirect_to admin_projects_path, status: :see_other, notice: "Project was successfully destroyed."
        end
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:title, :description, :github_url, :live_url, :featured_image, :tags, :featured)
    end
  end
end
