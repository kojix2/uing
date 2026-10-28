require "./uing/version"
require "./uing/ext_key"
require "./uing/modifiers"
require "./uing/lib_ui/lib_ui"
require "./uing/numeric_value"
require "./uing/tm"

# Keep optional integrations out of the default entry point.
require "./uing/block_constructor"
require "./uing/box"
require "./uing/button"
require "./uing/checkbox"
require "./uing/color_button"
require "./uing/combobox"
require "./uing/control"
require "./uing/control_registry"
require "./uing/date_time_picker"
require "./uing/drop"
require "./uing/editable_combobox"
require "./uing/entry"
require "./uing/font_button"
require "./uing/font_descriptor"
require "./uing/form"
require "./uing/grid"
require "./uing/group"
require "./uing/image"
require "./uing/image_buffer"
require "./uing/image_view"
require "./uing/label"
require "./uing/menu"
require "./uing/menu_item"
require "./uing/multiline_entry"
require "./uing/orientation"
require "./uing/progress_bar"
require "./uing/radio_buttons"
require "./uing/separator"
require "./uing/slider"
require "./uing/spinbox"
require "./uing/tab"
require "./uing/table/table"
require "./uing/timer"
require "./uing/text_italic"
require "./uing/text_stretch"
require "./uing/text_weight"
require "./uing/toolbar"
require "./uing/window"
require "./uing/area/*"
require "./uing/grid/*"
require "./uing/table/*"

module UIng
  alias ErrorHandler = Proc(Exception, String, Nil)

  # Returns the build identifier reported by the linked libui-ng library.
  # This is diagnostic information, not a complete ABI compatibility check.
  def self.libui_version : String
    String.new(LibUI.version)
  end

  # Mutex for thread-safe access to callbacks
  @@callback_mutex = Mutex.new

  # libui-ng requires exactly one matching uninit for every successful init.
  # Keep that contract on the Crystal side so an accidental duplicate uninit
  # cannot enter a backend after its global state has been released.
  @@lifecycle_mutex = Mutex.new
  @@initialized = false

  # Optional application-defined callback error policy. Errors are always
  # logged; UI notification is left to the application.
  @@error_handler : ErrorHandler?

  # uiInitOptions is not used (but it is required)
  # See https://github.com/libui-ng/libui-ng/issues/208
  @@init_options = Pointer(LibUI::InitOptions).malloc
  # Set Size field for future libui-ng compatibility (currently unused)
  @@init_options.value.size = LibC::SizeT.new(sizeof(LibUI::InitOptions))

  # Keep managed timer callback data alive until libui-ng observes a stop or
  # uiUninit() cancels its native timers. A stopped Timer drops its user Proc
  # immediately, but its Box must remain valid until then.
  @@managed_timer_boxes = {} of Pointer(Void) => Timer

  # Temporary storage for queue_main callback boxes (automatically cleaned up)
  @@queue_callback_boxes = [] of Pointer(Void)

  # Storage for on_should_quit callback (libui-ng supports only one callback)
  @@should_quit_callback_box : Pointer(Void)?

  # Keep a process-lifetime callback available while replacing a user callback
  # during shutdown. This also protects applications linked against an older
  # libui-ng that does not reset uiOnShouldQuit() during uiUninit().
  DEFAULT_SHOULD_QUIT_CALLBACK = ->(_data : Pointer(Void)) : LibC::Int { 0_i32 }

  # Convert control to Pointer(LibUI::Control)
  protected def self.to_control(control : Control)
    control.check_available
    control.to_unsafe.as(Pointer(LibUI::Control))
  end

  protected def self.to_control(control)
    if control.is_a?(Pointer)
      control.as(Pointer(LibUI::Control))
    else
      control.to_unsafe.as(Pointer(LibUI::Control))
    end
  end

  # Convert string pointer to Crystal string
  # and free the pointer
  protected def self.string_from_pointer(str_ptr) : String?
    return if str_ptr.null?
    str = String.new(str_ptr)
    LibUI.free_text(str_ptr)
    str
  end

  # Copy a NULL-terminated array of paths before releasing it with libui-ng.
  protected def self.strings_from_pointer(array_ptr : Pointer(Pointer(LibC::Char))) : Array(String)?
    return if array_ptr.null?

    begin
      paths = [] of String
      index = 0
      until (path_ptr = array_ptr[index]).null?
        paths << String.new(path_ptr)
        index += 1
      end
      paths
    ensure
      LibUI.free_text_array(array_ptr)
    end
  end

  @[Experimental]
  def self.on_error(&handler : Exception, String -> Nil) : Nil
    @@callback_mutex.synchronize { @@error_handler = handler }
  end

  @[Experimental]
  def self.on_error(handler : Nil) : Nil
    @@callback_mutex.synchronize { @@error_handler = nil }
  end

  @[Experimental]
  # Equivalent to `on_error(nil)`.
  def self.clear_on_error : Nil
    on_error(nil)
  end

  # Handle callback errors by printing the error message and backtrace, then
  # invoking the application-defined policy when one has been configured.
  def self.handle_callback_error(ex : Exception, ctx : String = "callback")
    report_callback_error(ex, ctx)

    handler = @@callback_mutex.synchronize { @@error_handler }
    return unless handler

    begin
      handler.call(ex, ctx)
    rescue error
      Crystal::System.print_error "error handler failed: %s\n", error.message
    end
  end

  private def self.report_callback_error(ex : Exception, ctx : String) : Nil
    # As UIng is a UI library, applications may not have standard output available
    # Use Crystal's system error output to ensure error messages are properly logged
    Crystal::System.print_error "%s error: %s\n", ctx, ex.message
    if backtrace = ex.backtrace?
      backtrace.each { |frame| Crystal::System.print_error "  from %s\n", frame }
    end
  end

  def self.init : Nil
    @@lifecycle_mutex.synchronize do
      raise RuntimeError.new("UIng is already initialized") if @@initialized

      str_ptr = LibUI.init(@@init_options)
      unless str_ptr.null?
        err = String.new(str_ptr)
        LibUI.free_init_error(str_ptr)
        raise err
      end

      @@initialized = true
    end
  end

  def self.init(&)
    init
    begin
      yield
    ensure
      uninit
    end
  end

  def self.uninit : Nil
    @@lifecycle_mutex.synchronize do
      if @@initialized
        reset_should_quit_callback
        LibUI.uninit

        # Keep teardown atomic with respect to the next init. Otherwise another
        # fiber could initialize libui-ng between native uninit and invalidating
        # wrappers retained from the previous runtime.
        Menu.reset_after_uninit
        # Clear global callback storage after native shutdown.
        @@callback_mutex.synchronize do
          @@managed_timer_boxes.each_value(&.stop)
          @@managed_timer_boxes.clear
          @@queue_callback_boxes.clear
        end
        @@initialized = false
      end
    end
    nil
  end

  # should not be used.
  # See the implementation of `init` above.

  private def self.free_init_error(err) : Nil
    LibUI.free_init_error(err)
  end

  def self.main : Nil
    LibUI.main
  end

  def self.main_steps : Nil
    LibUI.main_steps
  end

  def self.main_step(wait : Bool) : Bool
    LibUI.main_step(wait ? 1 : 0) != 0
  end

  def self.quit : Nil
    LibUI.quit
  end

  def self.queue_main(&callback : -> Nil) : Nil
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    @@callback_mutex.synchronize do
      @@queue_callback_boxes << boxed_data
    end
    LibUI.queue_main(->(data) : Nil do
      begin
        data_as_callback = ::Box(typeof(callback)).unbox(data)
        data_as_callback.call
      rescue e
        UIng.handle_callback_error(e, "UIng.queue_main")
      ensure
        # Remove from global array after execution to prevent memory leak
        @@callback_mutex.synchronize do
          @@queue_callback_boxes.delete(data)
        end
      end
    end, boxed_data)
  end

  # Schedules a repeating callback on the UI thread at an interval given in
  # milliseconds. Return `true` to keep running or `false` to stop.
  def self.timer(milliseconds : Int, &callback : -> Bool) : Timer
    unless milliseconds > 0 && milliseconds <= Int32::MAX
      raise ArgumentError.new("timer interval must be between 1 and Int32::MAX milliseconds")
    end

    timer(milliseconds.to_i32.milliseconds, &callback)
  end

  # Schedules a repeating callback on the UI thread. Return `true` to keep
  # running or `false` to stop. The interval is rounded up to whole
  # milliseconds because libui-ng accepts only integer milliseconds.
  def self.timer(interval : Time::Span, &callback : -> Bool) : Timer
    unless interval > Time::Span.zero && interval <= Int32::MAX.milliseconds
      raise ArgumentError.new("timer interval must be positive and at most Int32::MAX milliseconds")
    end
    milliseconds = interval.total_milliseconds.ceil.to_i32

    timer = Timer.__create__(callback)
    boxed_data = ::Box.box(timer)

    @@lifecycle_mutex.synchronize do
      raise RuntimeError.new("UIng must be initialized before registering a timer") unless @@initialized

      @@callback_mutex.synchronize { @@managed_timer_boxes[boxed_data] = timer }
      begin
        LibUI.timer(milliseconds, ->(data) : LibC::Int do
          managed_timer = ::Box(Timer).unbox(data)
          keep_running = managed_timer.__tick__
          unless keep_running
            @@callback_mutex.synchronize { @@managed_timer_boxes.delete(data) }
          end
          keep_running ? 1_i32 : 0_i32
        end, boxed_data)
      rescue error
        @@callback_mutex.synchronize { @@managed_timer_boxes.delete(boxed_data) }
        timer.stop
        raise error
      end
    end

    timer
  end

  def self.on_should_quit(&callback : -> Bool) : Nil
    boxed_data = ::Box.box(callback)
    # Store in dedicated variable (libui-ng supports only one callback, overwrites previous)
    # Share the lifecycle lock with uninit so a concurrent registration cannot
    # store a new Box in libui-ng after its teardown has cleared the old one.
    @@lifecycle_mutex.synchronize do
      @@callback_mutex.synchronize do
        @@should_quit_callback_box = boxed_data
        LibUI.on_should_quit(->(data) : LibC::Int do
          begin
            data_as_callback = ::Box(typeof(callback)).unbox(data)
            data_as_callback.call ? 1 : 0
          rescue e
            UIng.handle_callback_error(e, "UIng.on_should_quit")
            0
          end
        end, boxed_data)
      end
    end
  end

  # Restores the default behavior of rejecting application-wide quit requests.
  # Equivalent to `on_should_quit(nil)`.
  def self.clear_on_should_quit : Nil
    @@lifecycle_mutex.synchronize { reset_should_quit_callback }
  end

  def self.on_should_quit(callback : Nil) : Nil
    clear_on_should_quit
  end

  private def self.reset_should_quit_callback : Nil
    @@callback_mutex.synchronize do
      LibUI.on_should_quit(DEFAULT_SHOULD_QUIT_CALLBACK, Pointer(Void).null)
      @@should_quit_callback_box = nil
    end
  end

  private def self.free_text(text) : Nil
    LibUI.free_text(text)
  end

  @[Deprecated("Use `msg_box` on Window instead")]
  def self.msg_box(parent, title, description) : Nil
    LibUI.msg_box(parent, title, description)
  end

  @[Deprecated("Use `msg_box_error` on Window instead")]
  def self.msg_box_error(parent, title, description) : Nil
    LibUI.msg_box_error(parent, title, description)
  end

  # Passing NULL is technically valid and handled by all platforms,
  # but it's considered better practice to provide a parent window
  def self.msg_box(title : String, description : String) : Nil
    LibUI.msg_box(nil, title, description)
  end

  # Passing NULL is technically valid and handled by all platforms,
  # but it's considered better practice to provide a parent window
  def self.msg_box_error(title : String, description : String) : Nil
    LibUI.msg_box_error(nil, title, description)
  end
end
