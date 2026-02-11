require "../src/uing"

class NotepadApp
  @current_file_path : String?
  @is_modified : Bool
  @main_window : UIng::Window
  @vbox : UIng::Box
  @entry : UIng::MultilineEntry

  def initialize
    @current_file_path = nil
    @is_modified = false

    UIng.init

    # Create menus and menu items BEFORE creating any windows
    file_menu = UIng::Menu.new("File")
    open_item = file_menu.append_item("Open")
    save_item = file_menu.append_item("Save")
    save_as_item = file_menu.append_item("Save As")
    file_menu.append_separator
    quit_item = file_menu.append_quit_item

    help_menu = UIng::Menu.new("Help")
    about_item = help_menu.append_about_item

    # Now create UI components
    @main_window = UIng::Window.new("Notepad", 500, 300, menubar: true)
    @vbox = UIng::Box.new(:vertical)
    @entry = UIng::MultilineEntry.new(wrapping: true)

    # Set up the window layout
    @main_window.child = @vbox
    @vbox.append @entry, true

    # Set up event handlers
    setup_event_handlers(open_item, save_item, save_as_item, quit_item, about_item)

    # Initialize title
    update_title
  end

  def setup_event_handlers(open_item, save_item, save_as_item, quit_item, about_item)
    # Track text changes
    @entry.on_changed do
      @is_modified = true
      update_title
    end

    # Open file functionality
    open_item.on_clicked do |window|
      if file_path = @main_window.open_file
        begin
          content = File.read(file_path)
          @entry.text = content
          @current_file_path = file_path
          @is_modified = false
          update_title
        rescue ex
          window.msg_box_error("Error", "Could not open file: #{ex.message}")
        end
      end
    end

    # Save file functionality
    save_item.on_clicked do |window|
      if @current_file_path
        begin
          if current_file_path = @current_file_path
            File.write(current_file_path, @entry.text || "")
          end
          @is_modified = false
          update_title
        rescue ex
          window.msg_box_error("Error", "Could not save file: #{ex.message}")
        end
      else
        # If no current file, act like Save As
        if file_path = @main_window.save_file
          begin
            File.write(file_path, @entry.text || "")
            @current_file_path = file_path
            @is_modified = false
            update_title
          rescue ex
            @main_window.msg_box_error("Error", "Could not save file: #{ex.message}")
          end
        end
      end
    end

    # Save As functionality
    save_as_item.on_clicked do |window|
      if file_path = @main_window.save_file
        begin
          File.write(file_path, @entry.text || "")
          @current_file_path = file_path
          @is_modified = false
          update_title
        rescue ex
          window.msg_box_error("Error", "Could not save file: #{ex.message}")
        end
      end
    end

    # Quit functionality - use UIng.on_should_quit instead of quit_item.on_clicked
    UIng.on_should_quit do
      if @is_modified
        # In a real application, you might want to show a confirmation dialog
        # For now, we'll just quit
      end
      cleanup
      true
    end

    # About functionality
    about_item.on_clicked do |window|
      window.msg_box("About Notepad", "Simple Notepad Application\nBuilt with UIng (Crystal binding for libui-ng)")
    end

    # Window closing handler
    @main_window.on_closing do
      if @is_modified
        # In a real application, you might want to show a save confirmation dialog
      else
      end
      UIng.quit
      true
    end
  end

  def update_title
    title = if current_file_path = @current_file_path
              filename = File.basename(current_file_path)
              modified_marker = @is_modified ? "*" : ""
              "#{modified_marker}#{filename} - Notepad"
            else
              modified_marker = @is_modified ? "*" : ""
              "#{modified_marker}Untitled - Notepad"
            end
    @main_window.title = title
  end

  def run
    @main_window.show
    UIng.main
    UIng.uninit
  end

  private def cleanup
    # See https://github.com/kojix2/uing/issues/19
    @vbox.delete(0)
    @entry.destroy
    @main_window.destroy
    puts "Bye Bye"
  end
end

# Create and run the application
app = NotepadApp.new
app.run
