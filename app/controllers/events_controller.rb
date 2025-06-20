class EventsController < ApplicationController
  def index
    @events = Event.active.order(created_at: :desc)
  end

  def show
    @event = Event.find(params[:id])
    @attendee = Attendee.new
  end
end
