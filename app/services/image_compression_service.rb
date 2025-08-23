class ImageCompressionService
  def self.compress(uploaded_file)
    # Skip if file is already under 10MB
    return uploaded_file if uploaded_file.size <= 10.megabytes

    target_size = 9.8.megabytes # Target close to 10MB but safe for Cloudinary
    original_size = uploaded_file.size

    begin
      # Create a working copy to avoid corrupting original
      temp_file = Tempfile.new(['compressed', '.jpg'])
      temp_file.binmode
      
      # Copy original file to working temp file
      File.open(uploaded_file.tempfile.path, 'rb') do |original|
        temp_file.write(original.read)
      end
      temp_file.rewind

      # Validate it's actually a processable image
      image = MiniMagick::Image.open(temp_file.path)
      
      # This will raise an error if it's not a valid image
      original_width = image.width
      original_height = image.height
      
      # Additional validation - ensure it's not corrupted
      if original_width <= 0 || original_height <= 0
        raise "Invalid image dimensions: #{original_width}x#{original_height}"
      end
      
      Rails.logger.info "Starting compression: #{original_size / 1.megabyte.to_f}MB, #{original_width}x#{original_height} (PRESERVING DIMENSIONS)"

      # Always optimize format and compression settings
      image.format 'jpeg'
      image.strip  # Remove metadata (EXIF data can be 100KB+)
      image.interlace 'Plane'  # Progressive JPEG for better compression
      
      # Quality-only compression - NO RESIZING
      # Start with high quality and work down until we hit target size
      quality_levels = [95, 90, 85, 80, 75, 70, 65, 60, 55, 50, 45, 40, 35, 30]
      
      # Store original temp file path for clean resets
      original_temp_path = temp_file.path.dup

      quality_levels.each do |quality|
        # Reset from original uploaded file each time to avoid quality degradation stacking
        File.open(uploaded_file.tempfile.path, 'rb') do |original|
          temp_file.rewind
          temp_file.truncate(0)
          temp_file.write(original.read)
        end
        temp_file.rewind

        image = MiniMagick::Image.open(temp_file.path)
        image.format 'jpeg'
        image.strip
        image.interlace 'Plane'
        image.quality quality.to_s
        image.write temp_file.path
        
        current_size = File.size(temp_file.path)
        size_mb = current_size / 1.megabyte.to_f
        
        Rails.logger.info "Quality #{quality}%: #{size_mb.round(2)}MB (#{original_width}x#{original_height})"
        
        if current_size <= target_size
          copy_temp_to_uploaded_file(temp_file, uploaded_file)
          Rails.logger.info "✅ Compression successful at #{quality}% quality: #{original_size / 1.megabyte.to_f}MB → #{size_mb.round(2)}MB (#{original_width}x#{original_height} preserved)"
          return uploaded_file
        end
      end
      
      # If we get here, even 30% quality didn't work
      # Return the 30% version anyway (best we can do without resizing)
      copy_temp_to_uploaded_file(temp_file, uploaded_file)
      final_size = File.size(uploaded_file.tempfile.path)
      
      Rails.logger.warn "⚠️ Could not reach target size with quality alone. Final: #{original_size / 1.megabyte.to_f}MB → #{(final_size / 1.megabyte.to_f).round(2)}MB at 30% quality (#{original_width}x#{original_height} preserved)"
      uploaded_file

    rescue StandardError => e
      Rails.logger.error "Image compression failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      uploaded_file # Return original if compression fails
    ensure
      temp_file&.close
      temp_file&.unlink
    end
  end

  private

  def self.copy_temp_to_uploaded_file(temp_file, uploaded_file)
    temp_file.rewind
    uploaded_file.tempfile.rewind
    uploaded_file.tempfile.truncate(0)
    uploaded_file.tempfile.write(temp_file.read)
    uploaded_file.tempfile.rewind
  end
end
