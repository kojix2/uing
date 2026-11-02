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
  @cleaned_up : Bool

  def initialize
    UIng.init
    @cleaned_up = false

    # Initialize UI components directly
    @hbox = UIng::Box.new :horizontal

    # Create initial table model and table directly in initialize
    model_handler = UIng::Table::Model::Handler.new do
      num_columns { @column_count > 0 ? @column_count : 1 }
      column_type { |_column| UIng::Table::Value::Type::String }
      num_rows { @csv_data.size }
      cell_value do |row, column|
        if row < @csv_data.size && column < @csv_data[row].size
          UIng::Table::Value.new(@csv_data[row][column])
        else
          UIng::Table::Value.new("")
        end
      end
      set_cell_value { |_row, _column, _value| }
    end

    @table_model = UIng::Table::Model.new(model_handler)

    @table = UIng::Table.new(@table_model) do
      if @column_count > 0
        (0...@column_count).each do |i|
          append_text_column(generate_column_name(i), i, editable: :never)
        end
      else
        # Default single column if no data loaded yet
        append_text_column("A", 0, editable: :never)
      end
    end

    @hbox.append(@table, true)

    # Menus must be created before windows with menubars.
    UIng::Menu.new("File") do
      open_item = append_item("Open")
      open_item.set_shortcut('O', UIng::Modifiers::Primary)
      open_item.on_clicked do |window|
        if filename = window.try &.open_file
          update_table_with_file(filename)
        end
      end
      append_separator
      append_quit_item
    end

    @window = UIng::Window.new("CSV Viewer", WINDOW_WIDTH, WINDOW_HEIGHT, menubar: true)
    @window.child = @hbox

    UIng.on_should_quit do
      cleanup
      @window.destroy unless @window.released?
      true
    end
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

  private def load_csv_data(filename : String) : Array(Array(String))?
    separator = File.extname(filename).downcase == ".tsv" ? '\t' : ','

    File.open(filename) do |file|
      new_data = CSV.parse(file, separator: separator)
      return if new_data.empty? || new_data.first.empty?

      puts "Loaded file: #{filename} (#{new_data.size} rows, #{new_data.first.size} columns)"
      new_data
    end
  rescue ex : Exception
    puts "Error loading file: #{ex.message}"
    nil
  end

  private def create_table_with_columns(column_count : Int32)
    model_handler = UIng::Table::Model::Handler.new do
      num_columns { column_count }
      column_type { |_column| UIng::Table::Value::Type::String }
      num_rows { @csv_data.size }
      cell_value do |row, column|
        if row < @csv_data.size && column < @csv_data[row].size
          UIng::Table::Value.new(@csv_data[row][column])
        else
          UIng::Table::Value.new("")
        end
      end
      set_cell_value { |_row, _column, _value| }
    end

    @table_model = UIng::Table::Model.new(model_handler)

    @table = UIng::Table.new(@table_model) do
      (0...column_count).each do |i|
        append_text_column(generate_column_name(i), i, editable: :never)
      end
    end

    @hbox.append(@table, true)
  end

  private def clear_table_data
    old_count = @csv_data.size
    (old_count - 1).downto(0) do |i|
      @csv_data.delete_at(i)
      @table_model.row_deleted(i)
    end
  end

  private def destroy_current_table
    @hbox.delete(0)
    @table.destroy
    @table_model.free
  end

  private def recreate_table(new_column_count : Int32, new_data : Array(Array(String)))
    puts "Column count changed from #{@column_count} to #{new_column_count}, recreating table"

    destroy_current_table
    @csv_data = new_data
    create_table_with_columns(new_column_count)

    puts "Table updated with new data"
  end

  private def update_existing_table(new_data : Array(Array(String)))
    clear_table_data
    new_data.each do |row_data|
      @csv_data << row_data
      @table_model.row_inserted(@csv_data.size - 1)
    end

    puts "Table updated with new data"
  end

  private def update_table_with_file(filename : String) : Bool
    puts "Opening file: #{filename}"

    # Parse first so a failed load leaves the displayed rows intact.
    new_data = load_csv_data(filename)
    return false unless new_data
    new_column_count = new_data.first.size

    if new_column_count != @column_count && new_column_count > 0
      recreate_table(new_column_count, new_data)
    else
      update_existing_table(new_data)
    end

    @column_count = new_column_count
    true
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
    return if @cleaned_up

    @cleaned_up = true
    @hbox.delete(0)
    @table.destroy
    @table_model.free
  end

  # Main application loop
  def run
    setup_initial_data

    @window.on_closing do
      cleanup
      UIng.quit
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
