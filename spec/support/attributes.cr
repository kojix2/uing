require "../spec_helper"

module SpecSupport
  class ReleasedLifetimeSafetyAttribute < UIng::Area::Attribute
    def initialize
      super(Pointer(UIng::LibUI::Attribute).null)
      @released = true
    end
  end
end
