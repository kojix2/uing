require "../src/uing"

UIng.init

vbox = UIng::Box.new(:vertical)

date_time_picker = UIng::DateTimePicker.new

time = UIng::TM.new

date_time_picker.on_changed do
  date_time_picker.time(time)
  p sec: time.sec,
    min: time.min,
    hour: time.hour,
    mday: time.mday,
    mon: time.mon,
    year: time.year,
    wday: time.wday,
    yday: time.yday,
    isdst: time.isdst
end
vbox.append(date_time_picker, 1)

main_window = UIng::Window.new("Date Time Pickers", 300, 200, true)
main_window.on_closing do
  puts "Bye Bye"
  UIng.quit
  1
end

main_window.set_child(vbox)
main_window.show

UIng.main
UIng.uninit
