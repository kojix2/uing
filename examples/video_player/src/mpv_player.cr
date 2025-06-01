require "./mpv_bindings"

class MPVPlayer
  @mpv : Void*
  @initialized : Bool = false

  def initialize
    @mpv = LibMPV.mpv_create
    if @mpv.null?
      raise "Failed to create MPV context"
    end
  end

  def set_window_handle(handle : Int64)
    result = LibMPV.mpv_set_property(@mpv, "wid", LibMPV::MPVFormat::Int64, pointerof(handle))
    if result < 0
      raise "Failed to set window handle: #{error_string(result)}"
    end
  end

  def set_video_output(vo : String)
    result = LibMPV.mpv_set_property_string(@mpv, "vo", vo)
    if result < 0
      raise "Failed to set video output: #{error_string(result)}"
    end
  end

  def initialize_player
    return if @initialized
    
    result = LibMPV.mpv_initialize(@mpv)
    if result < 0
      raise "Failed to initialize MPV: #{error_string(result)}"
    end
    @initialized = true
  end

  def load_file(path : String)
    ensure_initialized
    
    cmd = [path.to_unsafe, Pointer(UInt8).null]
    result = LibMPV.mpv_command_async(@mpv, 0_u64, ["loadfile".to_unsafe, path.to_unsafe, Pointer(UInt8).null].to_unsafe)
    if result < 0
      raise "Failed to load file: #{error_string(result)}"
    end
  end

  def play_pause
    ensure_initialized
    
    result = LibMPV.mpv_command_async(@mpv, 0_u64, ["cycle".to_unsafe, "pause".to_unsafe, Pointer(UInt8).null].to_unsafe)
    if result < 0
      raise "Failed to toggle play/pause: #{error_string(result)}"
    end
  end

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

  def finalize
    LibMPV.mpv_terminate_destroy(@mpv) unless @mpv.null?
  end

  private def ensure_initialized
    unless @initialized
      raise "MPV player not initialized. Call initialize_player first."
    end
  end
end
