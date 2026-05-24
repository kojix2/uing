require "./control"

module UIng
  class ImageView < Control
    enum ContentMode
      Center = 0
      Fit    = 1
    end

    block_constructor

    def initialize
      @ref_ptr = LibUI.new_image_view
    end

    def initialize(image : Image, mode : ContentMode = ContentMode::Fit)
      @ref_ptr = LibUI.new_image_view
      # uiImageViewSetImage copies/retains its own native image; the source Image may be freed after this call.
      LibUI.image_view_set_image(@ref_ptr, image.to_unsafe)
      LibUI.image_view_set_content_mode(@ref_ptr, mode)
    end

    def image=(image : Image?)
      # Unlike table image values, ImageView does not borrow the source Image.
      if image
        LibUI.image_view_set_image(@ref_ptr, image.to_unsafe)
      else
        LibUI.image_view_set_image(@ref_ptr, Pointer(LibUI::Image).null)
      end
    end

    def content_mode=(mode : ContentMode)
      LibUI.image_view_set_content_mode(@ref_ptr, mode)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
