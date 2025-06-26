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
    @photo.category = params[:category] if params[:category].present?
  end

  # GET /admin/photos/bulk_upload
  def bulk_upload
  end

  # GET /admin/photos/1/edit
  def edit
  end

  # POST /admin/photos or /admin/photos.json
  def create
    @photo = Photo.new(photo_params.except(:image))

    # Compress image if provided
    if params[:photo][:image].present?
      compressed_image = ImageCompressionService.compress(params[:photo][:image])
      @photo.image.attach(compressed_image)
    end

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
    # Handle image compression if a new image is being uploaded
    if params[:photo][:image].present?
      compressed_image = ImageCompressionService.compress(params[:photo][:image])
      @photo.image.attach(compressed_image)

      # Update other attributes separately (excluding image since we handled it above)
      update_params = photo_params.except(:image)
    else
      # No new image, update all other attributes normally
      update_params = photo_params
    end

    respond_to do |format|
      if @photo.update(update_params)
        format.html { redirect_to admin_photo_path(@photo), notice: "Photo was successfully updated." }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /admin/photos/bulk_create
    def bulk_create
    category = params[:category]
    location = params[:location]
    images = params[:images]

    # Filter out empty values and ensure we have actual file uploads
    valid_images = images&.reject { |img| img.blank? || img.is_a?(String) } || []

    if category.blank? || valid_images.empty?
      redirect_to bulk_upload_admin_photos_path, alert: "Please provide a category and select at least one image."
      return
    end

        successful_uploads = 0
    failed_uploads = 0
    error_messages = []

        valid_images.each do |image|
      begin
        # Compress image if it's too large
        compressed_image = ImageCompressionService.compress(image)

        photo = Photo.new(category: category, location: location)
        photo.image.attach(compressed_image)

        if photo.save
          successful_uploads += 1
        else
          failed_uploads += 1
          filename = image.respond_to?(:original_filename) ? image.original_filename : "unknown file"
          error_messages << "#{filename}: #{photo.errors.full_messages.join(', ')}"
        end
      rescue => e
        failed_uploads += 1
        filename = image.respond_to?(:original_filename) ? image.original_filename : "unknown file"
        error_messages << "#{filename}: Compression failed - #{e.message}"
      end
    end

    if failed_uploads == 0
      redirect_to admin_photos_path, notice: "Successfully uploaded #{successful_uploads} photos to '#{category}' category."
    else
      flash_message = "Uploaded #{successful_uploads} photos successfully."
      flash_message += " #{failed_uploads} failed: #{error_messages.join('; ')}" if failed_uploads > 0
      redirect_to admin_photos_path, alert: flash_message
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
      params.require(:photo).permit(:image, :category, :location)
    end
end
