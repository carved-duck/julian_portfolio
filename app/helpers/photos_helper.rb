# What a link needs to open the full-size photo viewer (photos/_photo_modal, photo_modal_controller.js).
module PhotosHelper
  def photo_viewer_data(photo)
    {
      bs_toggle: "modal",
      bs_target: "#photoModal",
      photo_url: cl_image_path(photo.image.key, width: 1600, height: 1200, crop: :fit, quality: :auto,
                                                fetch_format: :auto),
      photo_alt: "Photo from #{photo.category}"
    }
  end
end
