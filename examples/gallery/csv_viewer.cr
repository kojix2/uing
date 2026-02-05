require "../../src/uing"
require "csv"

class CSVViewer
  # Constants
  WINDOW_WIDTH         = 400
  WINDOW_HEIGHT        = 300
  SUPPORTED_EXTENSIONS = %w[.csv .tsv]

  # Instance variables
  @csv_data = [] of Array(String)
  @column_count = 0
  @table : UIng::Table
  @table_model : UIng::Table::Model
  @hbox : UIng::Box
  @window : UIng::Window

  def initialize
    UIng.init

    # Initialize UI components directly
    @hbox = UIng::Box.new :horizontal

    # Create initial table model and table directly in initialize
    model_handler = UIng::Table::Model::Handler.new do
      num_columns { @column_count > 0 ? @column_count : 1 }
      column_type { |column| UIng::Table::Value::Type::String }
      num_rows { @csv_data.size }
      cell_value do |row, column|
        if row < @csv_data.size && column < @csv_data[row].size
          UIng::Table::Value.new(@csv_data[row][column])
        else
          UIng::Table::Value.new("")
        end
      end
      set_cell_value { |row, column, value| }
    end

    @table_model = UIng::Table::Model.new(model_handler)

    @table = UIng::Table.new(@table_model) do
      if @column_count > 0
        (0...@column_count).each do |i|
          append_text_column(generate_column_name(i), i, -1)
        end
      else
        # Default single column if no data loaded yet
        append_text_column("A", 0, -1)
      end
    end

    @hbox.append(@table, true)

    # Create menu after UI components are initialized
    setup_menu

    @window = UIng::Window.new("CSV Viewer", WINDOW_WIDTH, WINDOW_HEIGHT, menubar: true)
    @window.child = @hbox
  end

  private def generate_column_name(index : Int32) : String
    result = ""
    temp = index
    while temp >= 0
      result = ('A'.ord + (temp % 26)).chr.to_s + result
      temp = temp // 26 - 1
    end
    result
  end

  private def load_csv_data(filename : String) : Int32
    separator = File.extname(filename).downcase == ".tsv" ? '\t' : ','

    File.open(filename) do |file|
      new_data = CSV.parse(file, separator: separator)
      return 0 if new_data.empty?

      @csv_data.clear
      @csv_data.concat(new_data)
      columns = @csv_data.first?.try(&.size) || 0
      puts "Loaded file: #{filename} (#{@csv_data.size} rows, #{columns} columns)"
      columns
    end
  rescue ex : Exception
    puts "Error loading file: #{ex.message}"
    0
  end

  private def create_table_with_columns(column_count : Int32)
    model_handler = UIng::Table::Model::Handler.new do
      num_columns { column_count }
      column_type { |column| UIng::Table::Value::Type::String }
      num_rows { @csv_data.size }
      cell_value do |row, column|
        if row < @csv_data.size && column < @csv_data[row].size
          UIng::Table::Value.new(@csv_data[row][column])
        else
          UIng::Table::Value.new("")
        end
      end
      set_cell_value { |row, column, value| }
    end

    @table_model = UIng::Table::Model.new(model_handler)

    @table = UIng::Table.new(@table_model) do
      (0...column_count).each do |i|
        append_text_column(generate_column_name(i), i, -1)
      end
    end

    @hbox.append(@table, true)
  end

  private def clear_table_data
    old_count = @csv_data.size
    (old_count - 1).downto(0) do |i|
      @table_model.row_deleted(i)
    end
  end

  private def destroy_current_table
    @hbox.delete(0)
    @table.destroy
    @table_model.free
  end

  private def recreate_table(new_column_count : Int32)
    puts "Column count changed from #{@column_count} to #{new_column_count}, recreating table"

    destroy_current_table
    create_table_with_columns(new_column_count)

    puts "Table updated with new data"
  end

  private def update_existing_table
    @csv_data.each_with_index do |_, i|
      @table_model.row_inserted(i)
    end

    puts "Table updated with new data"
  end

  private def update_table_with_file(filename : String) : Bool
    puts "Opening file: #{filename}"

    # Clear existing data
    clear_table_data

    new_column_count = load_csv_data(filename)
    return false if new_column_count == 0

    if new_column_count != @column_count && new_column_count > 0
      recreate_table(new_column_count)
    else
      update_existing_table
    end

    @column_count = new_column_count
    true
  end

  private def setup_menu
    UIng::Menu.new("File") do
      append_item("Open").on_clicked do |w|
        if filename = w.open_file
          update_table_with_file(filename)
        end
      end
      append_separator
      append_quit_item
    end
  end

  private def setup_initial_data
    return unless ARGV.size > 0

    filename = ARGV[0]
    return unless File.exists?(filename)

    extension = File.extname(filename).downcase
    if SUPPORTED_EXTENSIONS.includes?(extension)
      update_table_with_file(filename)
    else
      puts "Error: File must have #{SUPPORTED_EXTENSIONS.join(" or ")} extension"
    end
  end

  # Clean up resources
  private def cleanup
    @hbox.delete(0)
    @table.destroy
    @table_model.free
    UIng.quit
  end

  # Main application loop
  def run
    setup_initial_data

    @window.on_closing do
      cleanup
      true
    end

    @window.show
    UIng.main
  ensure
    UIng.uninit
  end
end

viewer = CSVViewer.new
viewer.run
