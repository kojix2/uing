require "../src/libui"

UIng.init

vbox = UIng.new_vertical_box

date_time_picker = UIng.new_date_time_picker

time = UIng::TM.new

UIng.date_time_picker_on_changed(date_time_picker) do
  UIng.date_time_picker_time(date_time_picker, time)
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
UIng.box_append(vbox, date_time_picker, 1)

main_window = UIng.new_window("Date Time Pickers", 300, 200, 1)
UIng.window_on_closing(main_window) do
  puts "Bye Bye"
  UIng.quit
  1
end
UIng.window_set_child(main_window, vbox)
UIng.control_show(main_window)

UIng.main
UIng.uninit
