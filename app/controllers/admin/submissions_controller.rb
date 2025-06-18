class Admin::SubmissionsController < Admin::BaseController
  before_action :set_submission, only: %i[ show destroy ]

  # GET /admin/submissions
  def index
    @submissions = Submission.order(created_at: :desc)
  end

  # GET /admin/submissions/1
  def show
  end

  # DELETE /admin/submissions/1
  def destroy
    @submission.destroy!

    respond_to do |format|
      format.html { redirect_to admin_submissions_path, status: :see_other, notice: "Submission was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    def set_submission
      @submission = Submission.find(params[:id])
    end
end
