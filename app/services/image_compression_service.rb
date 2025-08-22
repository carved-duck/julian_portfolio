class ImageCompressionService
  def self.compress(uploaded_file)
    # Skip if file is already under 10MB
    return uploaded_file if uploaded_file.size <= 10.megabytes

    target_size = 9.5.megabytes # Target just under 10MB to be safe

    begin
      # Try different quality levels, starting high
      [95, 90, 85, 80, 75, 70, 65, 60].each do |quality|
        # Open fresh image for each attempt
        image = MiniMagick::Image.open(uploaded_file.tempfile.path)

        # Apply compression
        image.format 'jpeg'
        image.quality quality.to_s

        # Write to tempfile
        image.write uploaded_file.tempfile.path

        # Check if we've hit our target size
        if File.size(uploaded_file.tempfile.path) <= target_size
          Rails.logger.info "Compressed image to #{quality}% quality, final size: #{File.size(uploaded_file.tempfile.path) / 1.megabyte.to_f}MB"
          return uploaded_file
        end
      end

      # If still too large after 60% quality, try resizing
      image = MiniMagick::Image.open(uploaded_file.tempfile.path)
      image.resize '1600x1600>'
      image.quality '60'
      image.write uploaded_file.tempfile.path

      Rails.logger.info "Final compression with resize, size: #{File.size(uploaded_file.tempfile.path) / 1.megabyte.to_f}MB"
      uploaded_file
    rescue StandardError => e
      Rails.logger.error "Image compression failed: #{e.message}"
      uploaded_file # Return original if compression fails
    end
  end
end
