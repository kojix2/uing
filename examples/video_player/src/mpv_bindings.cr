# Crystal bindings for libmpv
# Based on mpv/client.h

# Set locale for proper numeric formatting
lib LibC
  fun setlocale(category : Int32, locale : UInt8*) : UInt8*
end

# Locale categories
LC_NUMERIC = 1

# GTK/GDK bindings for Linux window embedding
{% unless flag?(:darwin) %}
  @[Link("gtk-3")]
  lib LibGTK
    type GtkWidget = Void*
    type GdkWindow = Void*
    type GTypeInstance = Void*

    fun gtk_widget_realize(widget : GtkWidget) : Void
    fun gtk_widget_get_window(widget : GtkWidget) : GdkWindow
    fun g_type_name_from_instance(instance : GTypeInstance) : UInt8*
  end

  @[Link("gdk-3")]
  lib LibGDK
    fun gdk_x11_window_get_xid(window : LibGTK::GdkWindow) : UInt64
  end
{% end %}

@[Link("mpv")]
lib LibMPV
  # Basic MPV functions (used)
  fun mpv_create : Void*
  fun mpv_initialize(ctx : Void*) : Int32
  fun mpv_terminate_destroy(ctx : Void*) : Void

  # Property functions (used)
  fun mpv_set_property(ctx : Void*, name : UInt8*, format : MPVFormat, data : Void*) : Int32
  fun mpv_set_property_string(ctx : Void*, name : UInt8*, data : UInt8*) : Int32
  fun mpv_get_property_string(ctx : Void*, name : UInt8*) : UInt8*
  fun mpv_get_property_async(ctx : Void*, reply_userdata : UInt64, name : UInt8*, format : MPVFormat) : Int32
  fun mpv_observe_property(ctx : Void*, reply_userdata : UInt64, name : UInt8*, format : MPVFormat) : Int32

  # Command functions (used)
  fun mpv_command_async(ctx : Void*, reply_userdata : UInt64, args : UInt8**) : Int32

  # Event functions (used)
  fun mpv_wait_event(ctx : Void*, timeout : Float64) : MPVEvent*

  # Utility functions (used)
  fun mpv_free(data : Void*) : Void

  # Error functions (used)
  fun mpv_error_string(error : Int32) : UInt8*
  fun mpv_event_name(event : Int32) : UInt8*

  # Enums (used)
  enum MPVFormat
    None      = 0
    String    = 1
    OSDString = 2
    Int64     = 4
  end

  enum MPVEventID
    None             =  0
    LogMessage       =  2
    GetPropertyReply =  3
    CommandReply     =  5
    StartFile        =  6
    EndFile          =  7
    FileLoaded       =  8
    Idle             = 11
    VideoReconfig    = 17
    AudioReconfig    = 18
    PlaybackRestart  = 19
    PropertyChange   = 20
  end

  # Structures (used)
  struct MPVEvent
    event_id : MPVEventID
    error : Int32
    reply_userdata : UInt64
    data : Void*
  end

  struct MPVEventProperty
    name : UInt8*
    format : MPVFormat
    data : Void*
  end

  struct MPVEventLogMessage
    prefix : UInt8*
    level : UInt8*
    text : UInt8*
    log_level : MPVLogLevel
  end

  struct MPVEventEndFile
    reason : Int32
    error : Int32
  end

  enum MPVLogLevel
    None  =  0
    Fatal = 10
    Error = 20
    Warn  = 30
    Info  = 40
    V     = 50
    Debug = 60
    Trace = 70
  end
end
