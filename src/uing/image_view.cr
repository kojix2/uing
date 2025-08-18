require "./control"

module UIng
  class ImageView < Control
    enum ContentMode
      Center
      Fit
      Fill
    end

    block_constructor

    def initialize
      @ref_ptr = LibUI.new_image_view
    end

    def initialize(image : Image, mode : ContentMode = ContentMode::Center)
      @ref_ptr = LibUI.new_image_view
      LibUI.image_view_set_image(@ref_ptr, image.to_unsafe)
      LibUI.image_view_set_content_mode(@ref_ptr, mode)
    end

    def image=(image : Image)
      LibUI.image_view_set_image(@ref_ptr, image.to_unsafe)
    end

    def content_mode=(mode : ContentMode)
      LibUI.image_view_set_content_mode(@ref_ptr, mode)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
