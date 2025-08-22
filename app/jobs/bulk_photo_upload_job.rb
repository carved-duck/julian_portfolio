class BulkPhotoUploadJob < ApplicationJob
  queue_as :default

  def perform(blob_id, category, location)
    # Find the blob
    blob = ActiveStorage::Blob.find(blob_id)

    # Download and compress the image
    blob.open do |file|
      # Create a temporary UploadedFile object for compression
      temp_uploaded_file = ActionDispatch::Http::UploadedFile.new(
        tempfile: file,
        filename: blob.filename.to_s,
        type: blob.content_type
      )

      # Compress the image
      compressed_file = ImageCompressionService.compress(temp_uploaded_file)

      # Create the photo record and attach compressed image
      photo = Photo.new(category: category, location: location)
      photo.image.attach(compressed_file)

      if photo.save
        Rails.logger.info "Successfully processed photo: #{blob.filename} to category '#{category}'"

        # Clean up the original blob since we've created a new compressed one
        blob.destroy
      else
        Rails.logger.error "Failed to save photo #{blob.filename}: #{photo.errors.full_messages.join(', ')}"
      end
    end
  rescue StandardError => e
    Rails.logger.error "Failed to process photo upload (blob_id: #{blob_id}): #{e.message}"
  end
end
