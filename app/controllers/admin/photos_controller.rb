class Admin::PhotosController < Admin::BaseController
  before_action :set_photo, only: %i[ show edit update destroy ]

  # GET /admin/photos or /admin/photos.json
  def index
    @photos = Photo.all
  end

  # GET /admin/photos/1 or /admin/photos/1.json
  def show
  end

  # GET /admin/photos/new
  def new
    @photo = Photo.new
  end

  # GET /admin/photos/1/edit
  def edit
  end

  # POST /admin/photos or /admin/photos.json
  def create
    @photo = Photo.new(photo_params)

    respond_to do |format|
      if @photo.save
        format.html { redirect_to admin_photo_path(@photo), notice: "Photo was successfully created." }
        format.json { render :show, status: :created, location: @photo }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/photos/1 or /admin/photos/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to admin_photo_path(@photo), notice: "Photo was successfully updated." }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/photos/1 or /admin/photos/1.json
  def destroy
    @photo.destroy!

    respond_to do |format|
      format.html { redirect_to admin_photos_path, status: :see_other, notice: "Photo was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def photo_params
      params.require(:photo).permit(:image, :category)
    end
end
