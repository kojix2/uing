require "../../src/uing"
require "./src/mpv_bindings"
require "./src/mpv_player"

# Default video URL (Big Buck Bunny from archive.org)
BLENDER_OPEN_MOVIE = "https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4"
PLAY_ICON          = "▶"
PAUSE_ICON         = "⏸"
MUTE_ICON          = "🔇"
UNMUTE_ICON        = "🔈"
INITIAL_VOLUME     = 70

# Video Player Application using libmpv and UIng
class VideoPlayerApp
  @main_window : UIng::Window?
  @video_area : UIng::Area?
  @source_entry : UIng::Entry?
  @play_button : UIng::Button?
  @mute_button : UIng::Button?
  @seek_slider : UIng::Slider?
  @volume_slider : UIng::Slider?
  @title_label : UIng::Label?
  @size_label : UIng::Label?
  @current_time_label : UIng::Label?
  @duration_label : UIng::Label?
  @mpv_player : MPVPlayer?
  @video_width : Int64 = 0_i64
  @video_height : Int64 = 0_i64
  @syncing_controls = false

  def initialize(@video_file : String)
  end

  def create_area_handler
    handler = UIng::Area::Handler.new

    # Draw handler - simple drawing for now
    handler.draw do |_, _|
      # For now, just do basic drawing - mpv rendering will be handled separately
      # TODO: Integrate mpv rendering here once we solve the closure issue
    end

    # Mouse event handler - do nothing for now
    handler.mouse_event do |_, _|
      # Could add mouse controls here
    end

    # Mouse crossed handler
    handler.mouse_crossed do |_, _|
      # Do nothing
    end

    # Drag broken handler
    handler.drag_broken do |_|
      # Do nothing
    end

    # Key event handler - reject all keys for now
    handler.key_event do |_, _|
      false # Reject all keys
    end

    handler
  end

  def on_play_pause_clicked
    with_player_action("toggling play/pause") do |player|
      player.play_pause
    end
  end

  def on_mute_clicked
    with_player_action("toggling mute", refresh: true) do |player|
      player.toggle_mute
    end
  end

  def on_seek_released(value : Int32)
    return if @syncing_controls

    with_player_action("seeking video", refresh: true) do |player|
      player.seek_to(value)
    end
  end

  def on_volume_changed(value : Int32)
    return if @syncing_controls

    with_player_action("changing volume", refresh: true) do |player|
      player.set_volume(value)
    end
  end

  def on_load_clicked
    source = source_entry.text.to_s.strip
    return if source.empty?

    @video_file = source
    @title_label.try(&.text=("Loading..."))

    with_player_action("loading source") do |player|
      player.load_file(source)
    end
  rescue ex
    puts "Error loading source: #{ex.message}"
    @title_label.try(&.text=("Failed to load source"))
  end

  def process_mpv_events
    player = @mpv_player
    return 1 unless player

    player.process_events do |event|
      puts "MPV Event: #{player.event_name(event.event_id.to_i32)}"

      handle_mpv_event(player, event)
    end

    refresh_playback_ui(player)

    1
  rescue ex
    puts "Error processing MPV events: #{ex.message}"

    1 # Continue timer
  end

  def update_size_label
    if @video_width > 0 && @video_height > 0
      size_text = "#{@video_width}x#{@video_height}"
      @size_label.try(&.text=(size_text))
    end
  end

  private def refresh_playback_ui(player : MPVPlayer)
    @syncing_controls = true

    update_transport_buttons(player)

    current_seconds = player.playback_position_seconds || 0
    duration_seconds = player.duration_seconds || 0
    seek_max = {duration_seconds, 1}.max

    update_seek_display(current_seconds, duration_seconds, seek_max)

    if volume = player.volume
      volume_slider.value = volume.clamp(0, 100)
    end
  ensure
    @syncing_controls = false
  end

  private def update_transport_buttons(player : MPVPlayer)
    play_button.text = player.paused? ? PLAY_ICON : PAUSE_ICON
    mute_button.text = player.muted? ? UNMUTE_ICON : MUTE_ICON
  end

  private def update_seek_display(
    current_seconds : Int32,
    duration_seconds : Int32,
    seek_max : Int32,
  )
    seek_slider.set_range(0, seek_max)
    seek_slider.value = current_seconds.clamp(0, seek_max)
    current_time_label.text = format_timestamp(current_seconds)
    duration_label.text = format_timestamp(duration_seconds)
  end

  private def format_timestamp(total_seconds : Int32) : String
    seconds = total_seconds.clamp(0, Int32::MAX)
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    remaining_seconds = seconds % 60

    if hours > 0
      "%02d:%02d:%02d" % {hours, minutes, remaining_seconds}
    else
      "%02d:%02d" % {minutes, remaining_seconds}
    end
  end

  private def handle_mpv_event(player : MPVPlayer, event : LibMPV::MPVEvent)
    case event.event_id
    when LibMPV::MPVEventID::LogMessage
      handle_log_message(event)
    when LibMPV::MPVEventID::VideoReconfig
      handle_video_reconfig(player)
    when LibMPV::MPVEventID::EndFile
      handle_end_file(player, event)
    when LibMPV::MPVEventID::PropertyChange
      handle_property_change(player, event)
    when LibMPV::MPVEventID::GetPropertyReply
      handle_property_reply(event)
    end
  end

  private def handle_log_message(event : LibMPV::MPVEvent)
    data = event.data
    return unless data

    log_data = data.as(LibMPV::MPVEventLogMessage*).value
    return if log_data.prefix.null? || log_data.text.null?

    prefix = String.new(log_data.prefix)
    text = String.new(log_data.text).strip
    puts "[MPV #{prefix}] #{text}"
  end

  private def handle_video_reconfig(player : MPVPlayer)
    puts "Video reconfiguration detected"
    player.get_property_async("dwidth", LibMPV::MPVFormat::Int64)
    player.get_property_async("dheight", LibMPV::MPVFormat::Int64)
  end

  private def handle_end_file(player : MPVPlayer, event : LibMPV::MPVEvent)
    data = event.data
    return unless data

    end_file = data.as(LibMPV::MPVEventEndFile*).value
    puts "End file event - reason: #{end_file.reason}, error: #{end_file.error}"
    return if end_file.error == 0

    puts "Playback error: #{player.error_string(end_file.error)}"
  end

  private def handle_property_change(player : MPVPlayer, event : LibMPV::MPVEvent)
    property = extract_property_data(event)
    return unless property

    case property[:name]
    when "media-title"
      player.get_property_async("media-title", LibMPV::MPVFormat::OSDString)
    end
  end

  private def handle_property_reply(event : LibMPV::MPVEvent)
    property = extract_property_data(event)
    return unless property

    case property[:name]
    when "media-title"
      update_title(property[:data])
    when "dwidth"
      update_dimension(property[:data], :width)
    when "dheight"
      update_dimension(property[:data], :height)
    end
  end

  private def extract_property_data(event : LibMPV::MPVEvent)
    data = event.data
    return unless data

    property = data.as(LibMPV::MPVEventProperty*).value
    return if property.format == LibMPV::MPVFormat::None || property.name.null?

    {name: String.new(property.name), format: property.format, data: property.data}
  end

  private def update_title(data : Void*)
    return if data.null?

    title_ptr = data.as(UInt8**).value
    return if title_ptr.null?

    @title_label.try(&.text=(String.new(title_ptr)))
  end

  private def update_dimension(data : Void*, axis : Symbol)
    return if data.null?

    value = data.as(Int64*).value
    case axis
    when :width
      @video_width = value
    when :height
      @video_height = value
    end

    update_size_label
  end

  def on_window_closing
    UIng.quit
    true
  end

  def on_should_quit
    true
  end

  def initialize_mpv_player
    @mpv_player = MPVPlayer.new
    player = mpv_player

    configure_player(player)
    player.load_file(@video_file)

    refresh_playback_ui(player)

    puts "Loading video: #{@video_file}"
  rescue ex
    puts "Error initializing video player: #{ex.message}"
    main_window.msg_box_error(
      "Error",
      "Failed to initialize video player: #{ex.message}"
    )
    UIng.quit
  end

  def run
    # Initialize UIng
    UIng.init

    # Create main window
    @main_window = UIng::Window.new("libmpv Video Player", 640, 480, true)
    main_window.margined = true
    main_window.on_closing { on_window_closing }

    # Create vertical box for layout
    vbox = UIng::Box.new(:vertical)
    vbox.padded = true
    main_window.child = vbox

    build_source_bar(vbox)
    build_info_bar(vbox)

    # Create video area
    handler = create_area_handler
    @video_area = UIng::Area.new(handler)
    vbox.append(video_area, true)

    build_transport_bar(vbox)

    # Use queue_main to initialize MPV after UI is ready (like C version)
    UIng.queue_main do
      initialize_mpv_player
    end

    # Show window
    main_window.show

    # Set up quit handler
    UIng.on_should_quit { on_should_quit }
    UIng.main
    UIng.uninit
  end

  private def configure_player(player : MPVPlayer)
    player.set_window_handle_from_area(video_area)
    player.initialize_player
    UIng.timer(350) { process_mpv_events }
    player.observe_property("media-title", LibMPV::MPVFormat::None)
    player.set_volume(INITIAL_VOLUME)
  end

  private def build_source_bar(container : UIng::Box)
    source_row = UIng::Box.new(:horizontal)
    source_row.padded = true
    container.append(source_row, false)

    source_label = UIng::Label.new("Source")
    source_row.append(source_label, false)

    @source_entry = UIng::Entry.new(:search)
    source_entry.text = @video_file
    source_row.append(source_entry, true)

    load_button = UIng::Button.new("Load")
    load_button.on_clicked { on_load_clicked }
    source_row.append(load_button, false)
  end

  private def build_info_bar(container : UIng::Box)
    info_row = UIng::Box.new(:horizontal)
    info_row.padded = true
    container.append(info_row, false)

    @title_label = UIng::Label.new("")
    info_row.append(title_label, true)

    @size_label = UIng::Label.new("")
    info_row.append(size_label, false)
  end

  private def build_transport_bar(container : UIng::Box)
    transport_row = UIng::Box.new(:horizontal)
    transport_row.padded = true
    container.append(transport_row, false)

    @play_button = UIng::Button.new(PAUSE_ICON)
    play_button.on_clicked { on_play_pause_clicked }
    transport_row.append(play_button, false)

    @current_time_label = UIng::Label.new("00:00")
    transport_row.append(current_time_label, false)

    @seek_slider = UIng::Slider.new(0, 100, 0)
    seek_slider.on_released { |value| on_seek_released(value) }
    transport_row.append(seek_slider, true)

    @duration_label = UIng::Label.new("00:00")
    transport_row.append(duration_label, false)

    @mute_button = UIng::Button.new(MUTE_ICON)
    mute_button.on_clicked { on_mute_clicked }
    transport_row.append(mute_button, false)

    @volume_slider = UIng::Slider.new(0, 100, INITIAL_VOLUME)
    volume_slider.on_changed { |value| on_volume_changed(value) }
    transport_row.append(volume_slider, false)
  end

  private def with_player_action(
    action : String,
    refresh : Bool = false,
    &block : MPVPlayer -> Nil
  )
    player = @mpv_player
    return unless player

    block.call(player)
    refresh_playback_ui(player) if refresh
  rescue ex
    raise ex if action == "loading source"

    puts "Error #{action}: #{ex.message}"
  end

  private def main_window : UIng::Window
    @main_window || raise "Main window has not been initialized"
  end

  private def video_area : UIng::Area
    @video_area || raise "Video area has not been initialized"
  end

  private def source_entry : UIng::Entry
    @source_entry || raise "Source entry has not been initialized"
  end

  private def play_button : UIng::Button
    @play_button || raise "Play button has not been initialized"
  end

  private def mute_button : UIng::Button
    @mute_button || raise "Mute button has not been initialized"
  end

  private def seek_slider : UIng::Slider
    @seek_slider || raise "Seek slider has not been initialized"
  end

  private def volume_slider : UIng::Slider
    @volume_slider || raise "Volume slider has not been initialized"
  end

  private def title_label : UIng::Label
    @title_label || raise "Title label has not been initialized"
  end

  private def size_label : UIng::Label
    @size_label || raise "Size label has not been initialized"
  end

  private def current_time_label : UIng::Label
    @current_time_label || raise "Current time label has not been initialized"
  end

  private def duration_label : UIng::Label
    @duration_label || raise "Duration label has not been initialized"
  end

  private def mpv_player : MPVPlayer
    @mpv_player || raise "MPV player has not been initialized"
  end
end

def main
  # Parse command line arguments
  video_file = ARGV[0]? || BLENDER_OPEN_MOVIE

  # Create and run the video player app
  app = VideoPlayerApp.new(video_file)
  app.run
end

# Run the application
main
