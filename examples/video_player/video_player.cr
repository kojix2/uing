require "../../src/uing"
require "./src/mpv_bindings"
require "./src/mpv_player"

# Default video URL (Big Buck Bunny from archive.org)
BLENDER_OPEN_MOVIE = "https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4"

# Global variables
main_window : UIng::Window? = nil
video_area : UIng::Area? = nil
title_label : UIng::Label? = nil
size_label : UIng::Label? = nil
mpv_player : MPVPlayer? = nil

# Video dimensions tracking
video_width = 0_i64
video_height = 0_i64

def create_area_handler
  handler = UIng::AreaHandler.new
  
  # Draw handler - do nothing, mpv will handle rendering
  handler.draw do |area_handler, area, area_draw_params|
    # MPV handles all drawing
  end
  
  # Mouse event handler - do nothing for now
  handler.mouse_event do |area_handler, area, mouse_event|
    # Could add mouse controls here
  end
  
  # Mouse crossed handler
  handler.mouse_crossed do |area_handler, area, left|
    # Do nothing
  end
  
  # Drag broken handler
  handler.drag_broken do |area_handler, area|
    # Do nothing
  end
  
  # Key event handler - reject all keys for now
  handler.key_event do |area_handler, area, key_event|
    0 # Reject all keys
  end
  
  handler
end

def on_play_pause_clicked
  player = mpv_player
  return unless player
  
  begin
    player.play_pause
  rescue ex
    puts "Error toggling play/pause: #{ex.message}"
  end
end

def process_mpv_events
  player = mpv_player
  return 1 unless player
  
  begin
    player.process_events do |event|
      puts "MPV Event: #{player.event_name(event.event_id.to_i32)}"
      
      case event.event_id
      when LibMPV::MPVEventID::VideoReconfig
        # Request video dimensions
        player.get_property_async("dwidth", LibMPV::MPVFormat::Int64)
        player.get_property_async("dheight", LibMPV::MPVFormat::Int64)
      when LibMPV::MPVEventID::PropertyChange
        # Handle property changes
        if event.data
          prop = event.data.as(LibMPV::MPVEventProperty*)
          prop_data = prop.value
          
          if prop_data.format != LibMPV::MPVFormat::None && !prop_data.name.null?
            prop_name = String.new(prop_data.name)
            
            case prop_name
            when "media-title"
              player.get_property_async("media-title", LibMPV::MPVFormat::OSDString)
            end
          end
        end
      when LibMPV::MPVEventID::GetPropertyReply
        # Handle property replies
        if event.data
          prop = event.data.as(LibMPV::MPVEventProperty*)
          prop_data = prop.value
          
          if prop_data.format != LibMPV::MPVFormat::None && !prop_data.name.null?
            prop_name = String.new(prop_data.name)
            
            case prop_name
            when "media-title"
              if prop_data.format == LibMPV::MPVFormat::String || prop_data.format == LibMPV::MPVFormat::OSDString
                if prop_data.data && !prop_data.data.as(UInt8**).value.null?
                  title = String.new(prop_data.data.as(UInt8**).value)
                  title_label.try(&.text=(title))
                end
              end
            when "dwidth"
              if prop_data.format == LibMPV::MPVFormat::Int64 && prop_data.data
                video_width = prop_data.data.as(Int64*).value
                update_size_label
              end
            when "dheight"
              if prop_data.format == LibMPV::MPVFormat::Int64 && prop_data.data
                video_height = prop_data.data.as(Int64*).value
                update_size_label
              end
            end
          end
        end
      end
    end
  rescue ex
    puts "Error processing MPV events: #{ex.message}"
  end
  
  1 # Continue timer
end

def update_size_label
  if video_width > 0 && video_height > 0
    size_text = "#{video_width}x#{video_height}"
    size_label.try(&.text=(size_text))
  end
end

def on_window_closing
  UIng.quit
  1
end

def on_should_quit
  1
end

def main
  # Parse command line arguments
  video_file = ARGV[0]? || BLENDER_OPEN_MOVIE
  
  # Initialize UIng
  UIng.init
  
  # Create main window
  main_window = UIng::Window.new("libmpv Video Player", 640, 480, true)
  main_window.margined = true
  main_window.on_closing { on_window_closing }
  
  # Create vertical box for layout
  vbox = UIng::Box.new(:vertical)
  vbox.padded = true
  main_window.child = vbox
  
  # Create horizontal box for controls
  hbox = UIng::Box.new(:horizontal)
  hbox.padded = true
  vbox.append(hbox, false)
  
  # Create play/pause button
  play_button = UIng::Button.new("Play / Pause")
  play_button.on_clicked { on_play_pause_clicked }
  hbox.append(play_button, false)
  
  # Create title label
  title_label = UIng::Label.new("")
  hbox.append(title_label, true)
  
  # Create size label
  size_label = UIng::Label.new("")
  hbox.append(size_label, false)
  
  # Create video area
  handler = create_area_handler
  video_area = UIng::Area.new(handler)
  vbox.append(video_area, true)
  
  # Initialize MPV player
  begin
    mpv_player = MPVPlayer.new
    
    # Get window handle for video embedding
    window_handle = UIng.control_handle(video_area).address
    mpv_player.set_window_handle(window_handle)
    
    # Initialize the player
    mpv_player.initialize_player
    
    # Set up event timer for MPV events
    UIng.timer(350) { process_mpv_events }
    
    # Observe properties we're interested in
    mpv_player.observe_property("media-title", LibMPV::MPVFormat::None)
    
    # Load the video file
    mpv_player.load_file(video_file)
    
    puts "Loading video: #{video_file}"
    
  rescue ex
    UIng.msg_box_error(main_window, "Error", "Failed to initialize video player: #{ex.message}")
    UIng.quit
    return
  end
  
  # Set up quit handler
  UIng.on_should_quit { on_should_quit }
  
  # Show window and start main loop
  main_window.show
  UIng.main
  UIng.uninit
end

# Run the application
main
