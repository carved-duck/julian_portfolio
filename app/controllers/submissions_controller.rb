class SubmissionsController < ApplicationController
  def create
    @submission = Submission.new(submission_params)
    if @submission.save
      redirect_to root_path, notice: "Thanks! We've received your info."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @submission = Submission.new
    @show_event_form = false
  end

  private

  def submission_params
    params.require(:submission).permit(:name, :instagram_handle)
  end
end
