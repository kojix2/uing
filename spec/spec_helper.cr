require "spec"
require "../src/uing"

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

module UIng
  @@expected_callback_error_for_spec : Tuple(String, String)? = nil

  # Suppress only the expected diagnostic; unexpected errors and GC warnings
  # still reach stderr. The application error handler is exercised as usual.
  def self.expect_callback_error_log(message : String, context : String, &)
    previous = @@expected_callback_error_for_spec
    @@expected_callback_error_for_spec = {message, context}
    begin
      yield
    ensure
      @@expected_callback_error_for_spec = previous
    end
  end

  private def self.report_callback_error(ex : Exception, ctx : String) : Nil
    return if @@expected_callback_error_for_spec == {ex.message, ctx}
    previous_def
  end
end
