require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  # Observe allocation on a failing constructor without adding a production hook.
  private class AllocationObservedImageView < UIng::ImageView
    class_getter? allocated_before_failure = false

    def initialize(image : UIng::Image)
      @ref_ptr = Pointer(UIng::LibUI::ImageView).null
      begin
        super(image)
      rescue error
        @@allocated_before_failure = !@ref_ptr.null?
        # A regression must fail the test without leaking the observed allocation.
        UIng::LibUI.control_destroy(@ref_ptr.as(UIng::LibUI::Control*)) unless @ref_ptr.null?
        raise error
      end
    end
  end

  describe UIng::ImageView do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "rejects a freed source before allocating a native view" do
      image = UIng::Image.new(1, 1)
      image.free

      expect_raises(Exception, /already been released/) { AllocationObservedImageView.new(image) }

      AllocationObservedImageView.allocated_before_failure?.should be_false
    ensure
      image.try &.free
    end

    it "keeps its image usable after the source is freed" do
      image = UIng::Image.new(1, 1)
      image.append(Bytes[255, 0, 0, 255], 1, 1, 4)
      window = UIng::Window.new("ImageView ownership", 160, 80)
      view = UIng::ImageView.new(image, :center)
      window.child = view
      image.free

      view.to_unsafe.null?.should be_false
      view.content_mode = :fit
      view.image = nil
    ensure
      window.try &.destroy
      image.try &.free
    end
  end
{% end %}
