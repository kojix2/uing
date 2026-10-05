require "../../src/uing"

UIng.init

window = UIng::Window.new("Entry Example", 360, 220, margined: true)
window.on_closing do
  UIng.quit
  true
end

form = UIng::Form.new(padded: true)

standard_entry = UIng::Entry.new
standard_entry.text = "Type here"
form.append("Standard:", standard_entry)

search_entry = UIng::Entry.new(:search)
search_entry.text = "Search term"
form.append("Search:", search_entry)

password_entry = UIng::Entry.new(:password)
password_entry.text = "secret"
form.append("Password:", password_entry)

read_only_entry = UIng::Entry.new(read_only: true)
read_only_entry.text = "Read-only text"
form.append("Read only:", read_only_entry)

status = UIng::Label.new("Edit the standard entry")
standard_entry.on_changed do |text|
  status.text = "Standard entry: #{text}"
end

box = UIng::Box.new(:vertical, padded: true)
box.append(form)
box.append(status)

window.child = box
window.show

UIng.main
UIng.uninit
