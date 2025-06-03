require "./mpv_bindings"
require "./platform_embedding"

class MPVPlayer
  @mpv : Void*
  @initialized : Bool = false

  # ============================================================================
  # INITIALIZATION
  # ============================================================================

  def initialize
    # Set locale for proper numeric formatting
    LibC.setlocale(LC_NUMERIC, "C")

    @mpv = LibMPV.mpv_create
    if @mpv.null?
      raise "Failed to create MPV context"
    end

    # Set normal logging level
    set_property("msg-level", "all=info")

    # Configure MPV for embedding
    configure_for_embedding
  end

  def initialize_player
    return if @initialized

    result = LibMPV.mpv_initialize(@mpv)
    if result < 0
      raise "Failed to initialize MPV: #{error_string(result)}"
    end
    @initialized = true
  end

  def finalize
    LibMPV.mpv_terminate_destroy(@mpv) unless @mpv.null?
  end

  # ============================================================================
  # WINDOW EMBEDDING
  # ============================================================================

  def set_window_handle_from_area(area : UIng::Area)
    raw_handle = UIng.control_handle(area).address
    setup_platform_embedding(raw_handle)
  end

  private def setup_platform_embedding(raw_handle : UInt64)
    {% if flag?(:darwin) %}
      setup_macos_embedding(raw_handle)
    {% elsif flag?(:win32) %}
      setup_windows_embedding(raw_handle)
    {% else %}
      setup_linux_embedding(raw_handle)
    {% end %}
  end

  # Platform-specific embedding implementations
  {% if flag?(:darwin) %}
  include PlatformEmbedding::MacOS

  private def apply_platform_settings
    apply_macos_settings
  end
  {% elsif flag?(:win32) %}
  include PlatformEmbedding::Windows

  private def apply_platform_settings
    apply_windows_settings
  end
  {% else %}
  include PlatformEmbedding::Linux

  private def apply_platform_settings
    apply_linux_settings
  end
  {% end %}

  # ============================================================================
  # PLAYBACK CONTROL
  # ============================================================================

  def load_file(path : String)
    ensure_initialized

    puts "Loading file: #{path}"
    validate_file_path(path)

    result = LibMPV.mpv_command_async(@mpv, 0_u64, ["loadfile".to_unsafe, path.to_unsafe, Pointer(UInt8).null].to_unsafe)
    if result < 0
      raise "Failed to load file '#{path}': #{error_string(result)}"
    end
    
    puts "Load command sent successfully"
  end

  def play_pause
    ensure_initialized

    result = LibMPV.mpv_command_async(@mpv, 0_u64, ["cycle".to_unsafe, "pause".to_unsafe, Pointer(UInt8).null].to_unsafe)
    if result < 0
      raise "Failed to toggle play/pause: #{error_string(result)}"
    end
  end

  # ============================================================================
  # PROPERTY MANAGEMENT
  # ============================================================================

  def observe_property(name : String, format : LibMPV::MPVFormat = LibMPV::MPVFormat::None)
    ensure_initialized

    result = LibMPV.mpv_observe_property(@mpv, 0_u64, name, format)
    if result < 0
      raise "Failed to observe property #{name}: #{error_string(result)}"
    end
  end

  def get_property_string(name : String) : String?
    ensure_initialized

    str_ptr = LibMPV.mpv_get_property_string(@mpv, name)
    return nil if str_ptr.null?

    str = String.new(str_ptr)
    LibMPV.mpv_free(str_ptr.as(Void*))
    str
  end

  def get_property_async(name : String, format : LibMPV::MPVFormat = LibMPV::MPVFormat::String)
    ensure_initialized

    result = LibMPV.mpv_get_property_async(@mpv, 0_u64, name, format)
    if result < 0
      raise "Failed to get property #{name}: #{error_string(result)}"
    end
  end

  # ============================================================================
  # EVENT HANDLING
  # ============================================================================

  def wait_event(timeout : Float64 = 0.0) : LibMPV::MPVEvent?
    ensure_initialized

    event_ptr = LibMPV.mpv_wait_event(@mpv, timeout)
    return nil if event_ptr.null?

    event = event_ptr.value
    return nil if event.event_id == LibMPV::MPVEventID::None

    event
  end

  def process_events(&block : LibMPV::MPVEvent -> Void)
    while true
      event = wait_event(0.0)
      break unless event

      yield event
    end
  end

  # ============================================================================
  # UTILITY METHODS
  # ============================================================================

  def error_string(error_code : Int32) : String
    str_ptr = LibMPV.mpv_error_string(error_code)
    return "Unknown error" if str_ptr.null?
    String.new(str_ptr)
  end

  def event_name(event_id : Int32) : String
    str_ptr = LibMPV.mpv_event_name(event_id)
    return "Unknown event" if str_ptr.null?
    String.new(str_ptr)
  end

  # ============================================================================
  # PRIVATE METHODS
  # ============================================================================

  private def ensure_initialized
    unless @initialized
      raise "MPV player not initialized. Call initialize_player first."
    end
  end

  private def validate_file_path(path : String)
    # For URLs, skip file existence check
    return if path.starts_with?("http://") || path.starts_with?("https://")
    
    unless File.exists?(path)
      puts "Warning: File does not exist: #{path}"
    end
  end

  private def set_window_id(handle : Int64)
    result = LibMPV.mpv_set_property(@mpv, "wid", LibMPV::MPVFormat::Int64, pointerof(handle))
    if result < 0
      raise "Failed to set window handle: #{error_string(result)}"
    end
  end

  private def set_video_output(driver : String)
    result = LibMPV.mpv_set_property_string(@mpv, "vo", driver)
    if result < 0
      raise "Failed to set video output: #{error_string(result)}"
    end
  end

  private def set_property(name : String, value : String)
    LibMPV.mpv_set_property_string(@mpv, name, value)
  end

  # ============================================================================
  # CONFIGURATION
  # ============================================================================

  private def configure_for_embedding
    configure_video_output
    configure_embedding_options
  end

  private def configure_video_output
    {% if flag?(:darwin) %}
      set_property("vo", "gpu")
    {% elsif flag?(:win32) %}
      set_property("vo", "direct3d,gpu")
    {% else %}
      set_property("vo", "xv,x11")
    {% end %}
  end

  private def configure_embedding_options
    # Disable window decorations and controls
    set_property("input-default-bindings", "no")
    set_property("input-vo-keyboard", "no")
    set_property("osc", "no")

    # Set other embedding-friendly options
    set_property("border", "no")
    set_property("keepaspect", "yes")
    set_property("force-window", "no")
  end
end
