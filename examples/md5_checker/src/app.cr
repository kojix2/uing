require "uing"
require "./checker"
require "./table_handler"

# UI Application
class MD5CheckerApp
  @main_window : UIng::Window
  @file_path_label : UIng::Label
  @table_handler : MD5TableHandler
  @table_model : UIng::TableModel

  def initialize
    UIng.init

    @main_window = UIng::Window.new("MD5 Checker", 600, 400)
    @main_window.margined = true
    @main_window.on_closing do
      UIng.quit
      1
    end

    @file_path_label = UIng::Label.new("No file selected")

    # Create table model and handler
    @table_handler = MD5TableHandler.new
    @table_model = @table_handler.create_model

    setup_ui
  end

  # Run the application
  def run
    @main_window.show
    UIng.main
    cleanup
  end

  # Setup UI components
  private def setup_ui
    # Create layout
    main_vbox = UIng::Box.new(:vertical)
    main_vbox.padded = true
    @main_window.set_child(main_vbox)

    # Top box
    top_hbox = UIng::Box.new(:horizontal)
    top_hbox.padded = true
    main_vbox.append(top_hbox, false)

    # File path label
    top_hbox.append(@file_path_label, true)

    # File selection button
    select_button = UIng::Button.new("Select File")
    select_button.on_clicked { handle_file_selection }
    top_hbox.append(select_button, false)

    # Run button
    run_button = UIng::Button.new("Run")
    run_button.on_clicked { handle_run_button }
    top_hbox.append(run_button, false)

    # Create table
    table = create_table
    main_vbox.append(table, true)
  end

  # Create and configure table
  private def create_table
    table_params = UIng::TableParams.new
    table_params.model = @table_model
    table_params.row_background_color_model_column = -1

    table = UIng::Table.new(table_params)
    table.append_text_column("Filename", 0, -1, nil)
    table.append_text_column("Status", 1, -1, nil)
    table.append_text_column("Message", 2, -1, nil)

    # Table settings
    table.header_set_visible(true)
    table.set_selection_mode(UIng::TableSelectionMode::ZeroOrMany)

    table
  end

  # Handle file selection button click
  private def handle_file_selection
    path = UIng.open_file(@main_window)
    if path
      @file_path_label.set_text(path)
    end
  end

  # Handle run button click
  private def handle_run_button
    path = @file_path_label.text
    if path && path != "No file selected"
      process_md5_file(path)
    else
      UIng.msg_box_error(@main_window, "Error", "No file selected")
    end
  end

  # Process MD5 file and update table
  private def process_md5_file(path)
    # Record old row count
    old_row_count = MD5Checker.instance.result_count

    # Process md5.txt file
    MD5Checker.instance.process_md5_file(path)

    # Update table
    update_table(old_row_count, MD5Checker.instance.result_count)

    # Show completion dialog
    UIng.msg_box(@main_window, "Process Complete", "MD5 check completed")
  end

  # Update table with new data
  private def update_table(old_row_count, new_row_count)
    # Delete all old rows
    old_row_count.times do
      UIng.table_model_row_deleted(@table_model.to_unsafe, 0) # Always delete the first row
    end

    # Insert all new rows
    new_row_count.times do |i|
      UIng.table_model_row_inserted(@table_model.to_unsafe, i)
    end
  end

  # Cleanup resources
  private def cleanup
    UIng.free_table_model(@table_model)
    UIng.uninit
  end
end
