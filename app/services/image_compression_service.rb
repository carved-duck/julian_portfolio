class ImageCompressionService
  def self.compress(uploaded_file, max_size_mb: 10)
    # Skip if file is already under the limit
    return uploaded_file if uploaded_file.size <= max_size_mb.megabytes

    # Create temporary file for compression
    temp_file = Tempfile.new(['compressed', '.jpg'])

    begin
      # Use mini_magick to compress the image
      image = MiniMagick::Image.open(uploaded_file.tempfile.path)

      # Start with high quality and reduce if needed
      quality = 85

      loop do
        # Reset image for each iteration
        image = MiniMagick::Image.open(uploaded_file.tempfile.path)

        # Apply compression settings
        image.format 'jpeg'
        image.quality quality.to_s
        image.strip  # Remove metadata to save space

        # Resize if image is very large (max 2000px on longest side)
        if image.width > 2000 || image.height > 2000
          image.resize '2000x2000>'
        end

        # Write to temp file
        image.write temp_file.path

        # Check if file size is acceptable
        if File.size(temp_file.path) <= max_size_mb.megabytes || quality <= 50
          break
        end

        # Reduce quality for next iteration
        quality -= 10
      end

      # Create a new uploaded file object with compressed data
      ActionDispatch::Http::UploadedFile.new(
        tempfile: temp_file,
        filename: "compressed_#{uploaded_file.original_filename}",
        type: 'image/jpeg'
      )

    rescue => e
      Rails.logger.error "Image compression failed: #{e.message}"
      temp_file.close! if temp_file
      uploaded_file # Return original if compression fails
    end
  end
end
