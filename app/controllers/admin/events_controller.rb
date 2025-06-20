class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: %i[ show edit update destroy ]

  # GET /admin/events
  def index
    @events = Event.order(created_at: :desc)
  end

  # GET /admin/events/1
  def show
    @attendees = @event.attendees.recent
  end

  # GET /admin/events/new
  def new
    @event = Event.new
  end

  # GET /admin/events/1/edit
  def edit
  end

  # POST /admin/events
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to admin_event_path(@event), notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/events/1
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to admin_event_path(@event), notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/events/1
  def destroy
    @event.destroy!

    respond_to do |format|
      format.html { redirect_to admin_events_path, status: :see_other, notice: "Event was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:title, :description, :active)
    end
end
