module Admin
  class PhotosController < Admin::BaseController
    before_action :set_photo, only: %i[show edit update destroy feature unfeature]

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
      # Compress new image if provided
      if params[:photo][:image].present?
        compressed_image = ImageCompressionService.compress(params[:photo][:image])
        @photo.image.attach(compressed_image)
        update_params = photo_params.except(:image)
      else
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

      if category.blank? || images.blank?
        redirect_to bulk_upload_admin_photos_path, alert: "Please provide a category and select at least one image."
        return
      end

      successful_uploads = 0

      images.each do |image|
        next if image.blank?

        begin
          # Create blob first (fast) - no compression yet
          blob = ActiveStorage::Blob.create_and_upload!(
            io: image,
            filename: image.original_filename,
            content_type: image.content_type
          )

          # Queue background job with blob ID (serializable)
          BulkPhotoUploadJob.perform_later(blob.id, category, location)
          successful_uploads += 1
        rescue StandardError => e
          Rails.logger.error "Failed to create blob for #{image.original_filename}: #{e.message}"
        end
      end

      if successful_uploads.positive?
        redirect_to admin_photos_path,
                    notice: "Queued #{successful_uploads} photos for background processing. They will appear in the gallery shortly."
      else
        redirect_to bulk_upload_admin_photos_path, alert: "Failed to queue any photos for processing. Please try again."
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

    # DELETE /admin/photos/categories/:category_name
    def destroy_category
      category_name = params[:category_name]

      if category_name.blank?
        redirect_to admin_photos_path, alert: "Category name is required."
        return
      end

      photos_to_delete = Photo.where(category: category_name)
      photo_count = photos_to_delete.count

      if photo_count.zero?
        redirect_to admin_photos_path, alert: "No photos found in category '#{category_name}'."
        return
      end

      # Delete all photos in the category (this will also delete attached images)
      photos_to_delete.destroy_all

      redirect_to admin_photos_path, notice: "Deleted #{photo_count} photos from category '#{category_name}'."
    end

    # PATCH /admin/photos/1/feature
    def feature
      @photo.feature!
      redirect_to admin_photos_path, notice: "Photo was successfully featured."
    rescue StandardError => e
      redirect_to admin_photos_path, alert: "Failed to feature photo: #{e.message}"
    end

    # PATCH /admin/photos/1/unfeature
    def unfeature
      @photo.unfeature!
      redirect_to admin_photos_path, notice: "Photo was successfully unfeatured."
    rescue StandardError => e
      redirect_to admin_photos_path, alert: "Failed to unfeature photo: #{e.message}"
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
end
