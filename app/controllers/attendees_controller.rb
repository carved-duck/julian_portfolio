class AttendeesController < ApplicationController
  before_action :set_event

  def create
    @attendee = @event.attendees.build(attendee_params)

    # Check capacity before saving
    if @event.normal_event? && @event.at_capacity?
      redirect_to event_path(@event), alert: @event.capacity_full_message
      return
    end

    # Check if this signup will put us in pending zone BEFORE saving (BBQ events only)
    will_be_pending = false
    if @event.bbq_event? && @event.target_capacity.present?
      # Temporarily add 1 to simulate the new attendee
      original_count = @event.attendee_count
      @event.define_singleton_method(:attendee_count) { original_count + 1 }

      # Use the model's updated logic
      will_be_pending = @event.in_pending_zone?

      # Restore the original method
      @event.define_singleton_method(:attendee_count) { original_count }
    end

    if @attendee.save
      if will_be_pending
        # Store the pending status in session for confirmation modal (BBQ events only)
        session[:pending_signup] = {
          attendee_name: @attendee.name,
          event_title: @event.title,
          attendee_id: @attendee.id,
          event_id: @event.id
        }
        redirect_to event_path(@event, show_pending_modal: true)
      else
        redirect_to events_path, notice: success_message
      end
    else
      # Re-render the same @attendee: it carries the field errors and what the visitor typed.
      render 'events/show', status: :unprocessable_entity
    end
  end

  def confirm_pending
    # Confirm the pending signup
    if session[:pending_signup]
      attendee_name = session[:pending_signup][:attendee_name]
      event_title = session[:pending_signup][:event_title]
      session.delete(:pending_signup)
      redirect_to events_path,
                  notice: "✅ Thanks #{attendee_name}! Your signup for #{event_title} is confirmed. We'll keep you updated!"
    else
      redirect_to events_path
    end
  end

  def new
    @attendee = @event.attendees.build
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def success_message
    thanks = "🎉 Thanks #{@attendee.name}! You've successfully signed up for #{@event.title}."
    return "#{thanks} We'll be in touch soon!" unless @event.normal_event?
    return "#{thanks} Thanks for bringing #{@attendee.bringing}!" if @attendee.bringing_known?

    thanks
  end

  def attendee_params
    params.require(:attendee).permit(:name, :instagram_handle, :message, :bringing, :bringing_other)
  end
end
