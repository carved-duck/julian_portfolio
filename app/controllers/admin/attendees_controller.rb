class Admin::AttendeesController < Admin::BaseController
  before_action :set_event
  before_action :set_attendee, only: %i[ show edit update destroy ]

  # GET /admin/events/:event_id/attendees/:id
  def show
  end

  # GET /admin/events/:event_id/attendees/:id/edit
  def edit
  end

  # PATCH/PUT /admin/events/:event_id/attendees/:id
  def update
    respond_to do |format|
      if @attendee.update(attendee_params)
        format.html { redirect_to admin_event_attendee_path(@event, @attendee), notice: "Attendee was successfully updated." }
        format.json { render :show, status: :ok, location: @attendee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @attendee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/events/:event_id/attendees/:id
  def destroy
    @attendee.destroy!

    respond_to do |format|
      format.html { redirect_to admin_event_path(@event), status: :see_other, notice: "Attendee was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    def set_event
      @event = Event.find(params[:event_id])
    end

    def set_attendee
      @attendee = @event.attendees.find(params[:id])
    end

    def attendee_params
      params.require(:attendee).permit(:name, :instagram_handle, :message)
    end
end
