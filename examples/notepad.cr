require "../src/uing"

class NotepadApp
  @file_path : String?
  @dirty : Bool
  @window : UIng::Window
  @vbox : UIng::Box
  @entry : UIng::MultilineEntry

  def initialize
    @file_path = nil
    @dirty = false

    UIng.init

    # Create menus and menu items BEFORE creating any windows
    file_menu = UIng::Menu.new("File")
    open_item = file_menu.append_item("Open")
    save_item = file_menu.append_item("Save")
    save_as_item = file_menu.append_item("Save As")
    file_menu.append_separator
    file_menu.append_quit_item

    help_menu = UIng::Menu.new("Help")
    about_item = help_menu.append_about_item

    # Now create UI components
    @window = UIng::Window.new("Notepad", 500, 300, menubar: true)
    @vbox = UIng::Box.new(:vertical)
    @entry = UIng::MultilineEntry.new(wrapping: true)

    # Set up the window layout
    @window.child = @vbox
    @vbox.append @entry, true

    # Set up event handlers
    bind_events(open_item, save_item, save_as_item, about_item)

    # Initialize title
    refresh_title
  end

  def bind_events(open_item, save_item, save_as_item, about_item)
    bind_entry_changed
    bind_open(open_item)
    bind_save(save_item)
    bind_save_as(save_as_item)
    bind_quit
    bind_about(about_item)
    bind_window_closing
  end

  private def bind_entry_changed
    # Track text changes
    @entry.on_changed do
      @dirty = true
      refresh_title
    end
  end

  private def bind_open(open_item)
    # Open file functionality
    open_item.on_clicked do |window|
      if file_path = @window.open_file
        begin
          content = File.read(file_path)
          @entry.text = content
          @file_path = file_path
          @dirty = false
          refresh_title
        rescue ex
          window.msg_box_error("Error", "Could not open file: #{ex.message}")
        end
      end
    end
  end

  private def bind_save(save_item)
    # Save file functionality
    save_item.on_clicked do |window|
      if @file_path
        begin
          if path = @file_path
            File.write(path, @entry.text || "")
          end
          @dirty = false
          refresh_title
        rescue ex
          window.msg_box_error("Error", "Could not save file: #{ex.message}")
        end
      else
        # If no current file, act like Save As
        if file_path = @window.save_file
          begin
            File.write(file_path, @entry.text || "")
            @file_path = file_path
            @dirty = false
            refresh_title
          rescue ex
            @window.msg_box_error("Error", "Could not save file: #{ex.message}")
          end
        end
      end
    end
  end

  private def bind_save_as(save_as_item)
    # Save As functionality
    save_as_item.on_clicked do |window|
      if file_path = @window.save_file
        begin
          File.write(file_path, @entry.text || "")
          @file_path = file_path
          @dirty = false
          refresh_title
        rescue ex
          window.msg_box_error("Error", "Could not save file: #{ex.message}")
        end
      end
    end
  end

  private def bind_quit
    # Quit functionality - use UIng.on_should_quit instead of quit_item.on_clicked
    UIng.on_should_quit do
      if @dirty
        # In a real application, you might want to show a confirmation dialog
        # For now, we'll just quit
      end
      cleanup
      true
    end
  end

  private def bind_about(about_item)
    # About functionality
    about_item.on_clicked do |window|
      window.msg_box("About Notepad", "Simple Notepad Application\nBuilt with UIng (Crystal binding for libui-ng)")
    end
  end

  private def bind_window_closing
    # Window closing handler
    @window.on_closing do
      if @dirty
        # In a real application, you might want to show a save confirmation dialog
      else
      end
      UIng.quit
      true
    end
  end

  def refresh_title
    title = if path = @file_path
              filename = File.basename(path)
              modified_marker = @dirty ? "*" : ""
              "#{modified_marker}#{filename} - Notepad"
            else
              modified_marker = @dirty ? "*" : ""
              "#{modified_marker}Untitled - Notepad"
            end
    @window.title = title
  end

  def run
    @window.show
    UIng.main
    UIng.uninit
  end

  private def cleanup
    # See https://github.com/kojix2/uing/issues/19
    @vbox.delete(0)
    @entry.destroy
    @window.destroy
    puts "Bye Bye"
  end
end

# Create and run the application
app = NotepadApp.new
app.run
