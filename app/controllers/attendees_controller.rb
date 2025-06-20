class AttendeesController < ApplicationController
  before_action :set_event

  def create
    @attendee = @event.attendees.build(attendee_params)

    # Check if this signup will put us in pending zone BEFORE saving
    # We need to check the state after this attendee is added
    will_be_pending = false
    if @event.target_capacity.present?
      future_count = @event.attendee_count + 1

      # Don't warn if we haven't even reached the first table yet
      if future_count > 10 && future_count <= @event.target_capacity
        # Find which table "zone" we'll be in
        current_table = ((future_count - 1) / 10) + 1
        base_for_current_table = (current_table - 1) * 10
        next_table_starts_at = current_table * 10

        people_over_boundary = future_count - base_for_current_table
        people_until_next_table = next_table_starts_at - future_count

        # Will be pending if we're 1-7 people over a table boundary (leaving 3+ spots until next table)
        will_be_pending = people_over_boundary > 0 && people_until_next_table >= 3
      end
    end

    if @attendee.save
      if will_be_pending
        # Store the pending status in session for confirmation modal
        session[:pending_signup] = {
          attendee_name: @attendee.name,
          event_title: @event.title,
          attendee_id: @attendee.id,
          event_id: @event.id
        }
        redirect_to event_path(@event, show_pending_modal: true)
      else
        redirect_to events_path, notice: "🎉 Thanks #{@attendee.name}! You've successfully signed up for #{@event.title}. We'll be in touch soon!"
      end
    else
      flash.now[:alert] = "😔 Sorry, there was an issue with your signup. Please check the form and try again."
      render :new, status: :unprocessable_entity
    end
  end

  def confirm_pending
    # Confirm the pending signup
    if session[:pending_signup]
      attendee_name = session[:pending_signup][:attendee_name]
      event_title = session[:pending_signup][:event_title]
      session.delete(:pending_signup)
      redirect_to events_path, notice: "✅ Thanks #{attendee_name}! Your signup for #{event_title} is confirmed. We'll keep you updated!"
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
    params.require(:attendee).permit(:name, :instagram_handle, :message)
  end
end
