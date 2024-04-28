require "../src/libui"

LibUI.init

vbox = LibUI.new_vertical_box

date_time_picker = LibUI.new_date_time_picker

time = LibUI::TM.new

LibUI.date_time_picker_on_changed(date_time_picker) do
  LibUI.date_time_picker_time(date_time_picker, time)
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
LibUI.box_append(vbox, date_time_picker, 1)

main_window = LibUI.new_window("Date Time Pickers", 300, 200, 1)
LibUI.window_on_closing(main_window) do
  puts "Bye Bye"
  LibUI.quit
  1
end
LibUI.window_set_child(main_window, vbox)
LibUI.control_show(main_window)

LibUI.main
LibUI.uninit
