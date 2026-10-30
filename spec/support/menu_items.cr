require "../spec_helper"

module SpecSupport
  class LifetimeSafetyMenuItem < UIng::MenuItem
    getter? callback_was_retained_when_cleared = false
    getter callback_clear_count = 0

    def callback_retained? : Bool
      !@on_clicked_box.nil?
    end

    def initialize(callback_registered : Bool = true)
      super(Pointer(UIng::LibUI::MenuItem).null)
      @on_clicked_box = Pointer(Void).new(1_u64) if callback_registered
    end

    private def clear_native_callback : Nil
      @callback_clear_count += 1
      @callback_was_retained_when_cleared = !@on_clicked_box.nil?
    end
  end
end
