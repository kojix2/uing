# Crystal bindings for libmpv
# Based on mpv/client.h

# Set locale for proper numeric formatting
lib LibC
  fun setlocale(category : Int32, locale : UInt8*) : UInt8*
end

# Locale categories
LC_NUMERIC = 1

# GTK/GDK bindings for Linux window embedding
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

@[Link("mpv")]
lib LibMPV
  # Basic MPV functions
  fun mpv_create : Void*
  fun mpv_initialize(ctx : Void*) : Int32
  fun mpv_destroy(ctx : Void*) : Void
  fun mpv_terminate_destroy(ctx : Void*) : Void
  fun mpv_create_client(ctx : Void*, name : UInt8*) : Void*
  fun mpv_create_weak_client(ctx : Void*, name : UInt8*) : Void*
  fun mpv_load_config_file(ctx : Void*, filename : UInt8*) : Int32
  fun mpv_get_time_us(ctx : Void*) : Int64

  # Property functions
  fun mpv_set_property(ctx : Void*, name : UInt8*, format : MPVFormat, data : Void*) : Int32
  fun mpv_set_property_string(ctx : Void*, name : UInt8*, data : UInt8*) : Int32
  fun mpv_set_property_async(ctx : Void*, reply_userdata : UInt64, name : UInt8*, format : MPVFormat, data : Void*) : Int32
  fun mpv_get_property(ctx : Void*, name : UInt8*, format : MPVFormat, data : Void*) : Int32
  fun mpv_get_property_string(ctx : Void*, name : UInt8*) : UInt8*
  fun mpv_get_property_osd_string(ctx : Void*, name : UInt8*) : UInt8*
  fun mpv_get_property_async(ctx : Void*, reply_userdata : UInt64, name : UInt8*, format : MPVFormat) : Int32
  fun mpv_observe_property(ctx : Void*, reply_userdata : UInt64, name : UInt8*, format : MPVFormat) : Int32
  fun mpv_unobserve_property(ctx : Void*, registered_reply_userdata : UInt64) : Int32

  # Command functions
  fun mpv_command(ctx : Void*, args : UInt8**) : Int32
  fun mpv_command_node(ctx : Void*, args : MPVNode*, result : MPVNode*) : Int32
  fun mpv_command_ret(ctx : Void*, args : UInt8**, result : MPVNode*) : Int32
  fun mpv_command_string(ctx : Void*, args : UInt8*) : Int32
  fun mpv_command_async(ctx : Void*, reply_userdata : UInt64, args : UInt8**) : Int32
  fun mpv_command_node_async(ctx : Void*, reply_userdata : UInt64, args : MPVNode*) : Int32

  # Event functions
  fun mpv_wait_event(ctx : Void*, timeout : Float64) : MPVEvent*
  fun mpv_wakeup(ctx : Void*) : Void
  fun mpv_set_wakeup_callback(ctx : Void*, cb : (Void* -> Void), d : Void*) : Void
  fun mpv_wait_async_requests(ctx : Void*) : Void
  fun mpv_hook_add(ctx : Void*, reply_userdata : UInt64, name : UInt8*, priority : Int32) : Int32
  fun mpv_hook_continue(ctx : Void*, id : UInt64) : Int32

  # Utility functions
  fun mpv_get_wakeup_pipe(ctx : Void*) : Int32
  fun mpv_client_name(ctx : Void*) : UInt8*
  fun mpv_client_id(ctx : Void*) : Int64
  fun mpv_request_log_messages(ctx : Void*, min_level : UInt8*) : Int32
  fun mpv_free(data : Void*) : Void
  fun mpv_free_node_contents(node : MPVNode*) : Void

  # Error functions
  fun mpv_error_string(error : Int32) : UInt8*
  fun mpv_event_name(event : Int32) : UInt8*

  # Enums
  enum MPVFormat
    None      = 0
    String    = 1
    OSDString = 2
    Flag      = 3
    Int64     = 4
    Double    = 5
    Node      = 6
    NodeArray = 7
    NodeMap   = 8
    ByteArray = 9
  end

  enum MPVEventID
    None                =  0
    Shutdown            =  1
    LogMessage          =  2
    GetPropertyReply    =  3
    SetPropertyReply    =  4
    CommandReply        =  5
    StartFile           =  6
    EndFile             =  7
    FileLoaded          =  8
    TracksChanged       =  9
    TrackSwitched       = 10
    Idle                = 11
    Pause               = 12
    Unpause             = 13
    Tick                = 14
    ScriptInputDispatch = 15
    ClientMessage       = 16
    VideoReconfig       = 17
    AudioReconfig       = 18
    PlaybackRestart     = 19
    PropertyChange      = 20
    ChapterChange       = 21
    QueueOverflow       = 22
    Hook                = 23
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

  # Structures
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

  struct MPVEventScriptInputDispatch
    arg0 : Int32
    type : UInt8*
  end

  struct MPVEventClientMessage
    num_args : Int32
    args : UInt8**
  end

  struct MPVEventHook
    name : UInt8*
    id : UInt64
  end

  struct MPVNode
    format : MPVFormat
    u : MPVNodeUnion
  end

  union MPVNodeUnion
    string : UInt8*
    flag : Int32
    int64 : Int64
    double : Float64
    list : MPVNodeList*
    ba : MPVByteArray*
  end

  struct MPVNodeList
    num : Int32
    values : MPVNode*
    keys : UInt8**
  end

  struct MPVByteArray
    data : Void*
    size : LibC::SizeT
  end

  # Constants
  MPV_ERROR_SUCCESS              =   0
  MPV_ERROR_EVENT_QUEUE_FULL     =  -1
  MPV_ERROR_NOMEM                =  -2
  MPV_ERROR_UNINITIALIZED        =  -3
  MPV_ERROR_INVALID_PARAMETER    =  -4
  MPV_ERROR_OPTION_NOT_FOUND     =  -5
  MPV_ERROR_OPTION_FORMAT        =  -6
  MPV_ERROR_OPTION_ERROR         =  -7
  MPV_ERROR_PROPERTY_NOT_FOUND   =  -8
  MPV_ERROR_PROPERTY_FORMAT      =  -9
  MPV_ERROR_PROPERTY_UNAVAILABLE = -10
  MPV_ERROR_PROPERTY_ERROR       = -11
  MPV_ERROR_COMMAND              = -12
  MPV_ERROR_LOADING_FAILED       = -13
  MPV_ERROR_AO_INIT_FAILED       = -14
  MPV_ERROR_VO_INIT_FAILED       = -15
  MPV_ERROR_NOTHING_TO_PLAY      = -16
  MPV_ERROR_UNKNOWN_FORMAT       = -17
  MPV_ERROR_UNSUPPORTED          = -18
  MPV_ERROR_NOT_IMPLEMENTED      = -19
  MPV_ERROR_GENERIC              = -20
end
