require "./uing/version"
require "./uing/lib_ui/lib_ui"
require "./uing/tm"

require "./uing/*"
require "./uing/area/*"
require "./uing/attribute/*"
require "./uing/grid/*"
require "./uing/table/*"

module UIng
  # uiInitOptions is not used (but it is required)
  # See https://github.com/libui-ng/libui-ng/issues/208
  @@init_options = Pointer(LibUI::InitOptions).malloc

  # Global storage for special API callback boxes to prevent GC collection
  # This is a workaround for low-level APIs that don't have instance-level management
  # WARNING: This may cause memory leaks if callbacks are not properly cleaned up
  @@special_callback_boxes = [] of Pointer(Void)

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

  def self.init : Nil
    str_ptr = LibUI.init(@@init_options)
    return if str_ptr.null?
    err = String.new(str_ptr)
    LibUI.free_init_error(str_ptr)
    raise err
  end

  def self.init(&)
    self.init
    yield
    self.uninit
  end

  def self.init(init_options : Pointer(LibUI::InitOptions)) : String?
    @@init_options = init_options
    self.init
  end

  def self.uninit : Nil
    LibUI.uninit
    # Clear global callback array on uninit to prevent memory leaks
    @@special_callback_boxes.clear
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

  def self.queue_main(&callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    @@special_callback_boxes << boxed_data
    LibUI.queue_main(->(data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
      # Remove from global array after execution to prevent memory leak
      @@special_callback_boxes.delete(data)
    end, boxed_data)
  end

  def self.timer(sender, &callback : -> LibC::Int) : Nil
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    # NOTE: Timer callback removal behavior is not standardized in LibUI
    # See: https://github.com/andlabs/libui/pull/277
    @@special_callback_boxes << boxed_data
    LibUI.timer(sender, ->(data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.on_should_quit(&callback : -> Bool) : Nil
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    @@special_callback_boxes << boxed_data
    LibUI.on_should_quit(->(data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.free_text(text) : Nil
    LibUI.free_text(text)
  end

  def self.msg_box(parent, title, description) : Nil
    LibUI.msg_box(parent, title, description)
  end

  def self.msg_box_error(parent, title, description) : Nil
    LibUI.msg_box_error(parent, title, description)
  end
end
