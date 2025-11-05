class AttendeesController < ApplicationController
  before_action :set_event

  def create
    # Handle the "Other" bringing option for normal events
    processed_params = attendee_params
    if @event.normal_event? && processed_params[:bringing] == 'Other' && processed_params[:bringing_other].present?
      processed_params[:bringing] = processed_params[:bringing_other]
    end
    processed_params.delete(:bringing_other) # Remove the temporary field

    @attendee = @event.attendees.build(processed_params)

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
        success_message = if @event.normal_event?
                            "🎉 Thanks #{@attendee.name}! You've successfully signed up for #{@event.title}. Thanks for bringing #{@attendee.bringing}!"
                          else
                            "🎉 Thanks #{@attendee.name}! You've successfully signed up for #{@event.title}. We'll be in touch soon!"
                          end
        redirect_to events_path, notice: success_message
      end
    else
      flash.now[:alert] = "😔 Sorry, there was an issue with your signup. Please check the form and try again."
      @attendee = @event.attendees.build # Reset for re-render
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

  def attendee_params
    params.require(:attendee).permit(:name, :instagram_handle, :message, :bringing, :bringing_other)
  end
end
