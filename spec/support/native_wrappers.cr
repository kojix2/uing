require "../spec_helper"

# Test-only entry points for exercising native wrapper behavior without making
# pointer-taking constructors part of the public API.
class UIng::Image
  def self.from_native_for_spec(ref_ptr : Pointer(UIng::LibUI::Image)) : self
    new(ref_ptr)
  end
end

class UIng::Table::Value
  def self.owned_from_native_for_spec(ref_ptr : Pointer(UIng::LibUI::TableValue)) : self
    new(ref_ptr, borrowed: false)
  end
end

class UIng::Area::MouseEvent
  def self.from_native_for_spec(ref_ptr : UIng::LibUI::AreaMouseEvent*) : self
    new(ref_ptr)
  end
end

class UIng::Area::ScrollEvent
  def self.from_native_for_spec(ref_ptr : UIng::LibUI::AreaScrollEvent*) : self
    new(ref_ptr)
  end
end

class UIng::Area::KeyEvent
  def self.from_native_for_spec(ref_ptr : UIng::LibUI::AreaKeyEvent*) : self
    new(ref_ptr)
  end
end

class UIng::Area::Draw::Context
  def self.from_native_for_spec(ref_ptr : Pointer(UIng::LibUI::DrawContext)) : self
    new(ref_ptr)
  end
end

class UIng::Area::Draw::Path
  def self.from_native_for_spec(ref_ptr : Pointer(UIng::LibUI::DrawPath)) : self
    new(ref_ptr)
  end
end
