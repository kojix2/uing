require "./uing/version"
require "./uing/lib_ui/lib_ui"
require "./uing/tm"

require "./uing/*"
require "./uing/area/*"
require "./uing/grid/*"
require "./uing/table/*"

module UIng
  # Mutex for thread-safe access to callbacks
  @@callback_mutex = Mutex.new

  # uiInitOptions is not used (but it is required)
  # See https://github.com/libui-ng/libui-ng/issues/208
  @@init_options = Pointer(LibUI::InitOptions).malloc

  # Global storage for timer callback boxes to prevent GC collection
  # timer callbacks accumulate due to LibUI specification limitations
  @@timer_callback_boxes = [] of Pointer(Void)

  # Temporary storage for queue_main callback boxes (automatically cleaned up)
  @@queue_callback_boxes = [] of Pointer(Void)

  # Storage for on_should_quit callback (libui-ng supports only one callback)
  @@should_quit_callback_box : Pointer(Void)?

  # Convert control to Pointer(LibUI::Control)
  def self.to_control(control)
    if control.is_a?(Pointer)
      control.as(Pointer(LibUI::Control))
    else
      control.to_unsafe.as(Pointer(LibUI::Control))
    end
  end

  # Convert string pointer to Crystal string
  # and free the pointer
  def self.string_from_pointer(str_ptr) : String?
    return nil if str_ptr.null?
    str = String.new(str_ptr)
    LibUI.free_text(str_ptr)
    str
  end

  # Handle callback errors by printing the error message and backtrace
  def self.handle_callback_error(ex : Exception, ctx : String = "callback")
    # As UIng is a UI library, applications may not have standard output available
    # Use Crystal's system error output to ensure error messages are properly logged
    Crystal::System.print_error "%s error: %s\n", ctx, ex.message
    if backtrace = ex.backtrace?
      backtrace.each { |frame| Crystal::System.print_error "  from %s\n", frame }
    end
    # Show error message in a message box (system-level errors)
    UIng.msg_box_error("Error in #{ctx}", ex.message.to_s)
  end

  def self.init : Nil
    str_ptr = LibUI.init(@@init_options)
    return if str_ptr.null?
    err = String.new(str_ptr)
    LibUI.free_init_error(str_ptr)
    raise err
  end

  def self.init(&)
    init
    yield
    uninit
  end

  def self.init(init_options : Pointer(LibUI::InitOptions)) : String?
    @@init_options = init_options
    init
  end

  def self.uninit : Nil
    LibUI.uninit
    # Clear global callback arrays on uninit to prevent memory leaks
    @@callback_mutex.synchronize do
      @@timer_callback_boxes.clear
      @@queue_callback_boxes.clear
      @@should_quit_callback_box = nil
    end
  end

  # should not be used.
  # See the implementation of `init` above.

  def self.free_init_error(err) : Nil
    LibUI.free_init_error(err)
  end

  def self.main : Nil
    LibUI.main
  end

  def self.main_steps : Nil
    LibUI.main_steps
  end

  def self.main_step(wait) : Bool
    LibUI.main_step(wait)
  end

  def self.quit : Nil
    LibUI.quit
  end

  def self.queue_main(&callback : -> _) : Nil
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    @@callback_mutex.synchronize do
      @@queue_callback_boxes << boxed_data
    end
    LibUI.queue_main(->(data) do
      begin
        data_as_callback = ::Box(typeof(callback)).unbox(data)
        data_as_callback.call
      ensure
        # Remove from global array after execution to prevent memory leak
        @@callback_mutex.synchronize do
          @@queue_callback_boxes.delete(data)
        end
      end
    end, boxed_data)
  end

  def self.timer(sender, &callback : -> LibC::Int) : Nil
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    # NOTE: Timer callback removal behavior is not standardized in LibUI
    # See: https://github.com/andlabs/libui/pull/277
    @@callback_mutex.synchronize do
      @@timer_callback_boxes << boxed_data
    end
    LibUI.timer(sender, ->(data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      result = data_as_callback.call
      if result == 0
        @@callback_mutex.synchronize do
          @@timer_callback_boxes.delete(data)
        end
      end
      result
    end, boxed_data)
  end

  def self.on_should_quit(&callback : -> Bool) : Nil
    boxed_data = ::Box.box(callback)
    # Store in dedicated variable (libui-ng supports only one callback, overwrites previous)
    @@should_quit_callback_box = boxed_data
    LibUI.on_should_quit(->(data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.free_text(text) : Nil
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
