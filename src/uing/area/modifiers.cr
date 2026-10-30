module UIng
  class Area < Control
    # Kept for compatibility; Area events never report Modifiers::Primary.
    alias Modifiers = UIng::Modifiers
  end
end
