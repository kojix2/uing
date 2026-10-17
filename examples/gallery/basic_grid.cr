require "../../src/uing"

UIng.init

window = UIng::Window.new("Grid Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

grid = UIng::Grid.new(padded: true)

# Create a simple 3x3 grid layout
labels = [
  "Top Left", "Top Center", "Top Right",
  "Middle Left", "Center", "Middle Right",
  "Bottom Left", "Bottom Center", "Bottom Right",
]

labels.each_with_index do |text, index|
  row = index // 3
  col = index % 3

  label = UIng::Label.new(text)
  grid.append(label, left: col, top: row, hexpand: true, vexpand: true)
end

# Add a button that spans 2 columns at the bottom
button = UIng::Button.new("Span Button")
button.on_clicked do
  window.msg_box("Grid Demo", "This button spans 2 columns!")
end
grid.append(button, left: 0, top: 3, xspan: 2, hexpand: true)

# Add another button in the remaining space
another_button = UIng::Button.new("Single")
another_button.on_clicked do
  window.msg_box("Grid Demo", "Single column button!")
end
grid.append(another_button, left: 2, top: 3, hexpand: true)

window.child = grid
window.show

UIng.main
UIng.uninit
