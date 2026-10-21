module UIng
  # Keyboard modifier bits shared by Area events and menu shortcuts.
  # Primary means Command on macOS and Control on Windows/Linux.
  # Area events never report Primary; Super is invalid for menu shortcuts.
  @[Flags]
  enum Modifiers
    Ctrl    = 1 << 0
    Alt     = 1 << 1
    Shift   = 1 << 2
    Super   = 1 << 3
    Primary = 1 << 4
  end
end
