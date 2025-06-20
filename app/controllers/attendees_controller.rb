class AttendeesController < ApplicationController
  before_action :set_event

  def create
    @attendee = @event.attendees.build(attendee_params)
    if @attendee.save
      redirect_to events_path, notice: "🎉 Thanks #{@attendee.name}! You've successfully signed up for #{@event.title}. We'll be in touch soon!"
    else
      flash.now[:alert] = "😔 Sorry, there was an issue with your signup. Please check the form and try again."
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @attendee = @event.attendees.build
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def attendee_params
    params.require(:attendee).permit(:name, :instagram_handle, :message)
  end
end
