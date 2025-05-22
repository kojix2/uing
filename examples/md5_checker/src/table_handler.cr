require "uing"
require "./checker"

# Table model handler for MD5 checker
class MD5TableHandler
  def initialize
    @handler = UIng::TableModelHandler.new
    setup_handler
  end

  # Get the underlying handler
  def handler
    @handler
  end

  # Create a table model
  def create_model
    UIng::TableModel.new(@handler)
  end

  # Setup handler callbacks
  private def setup_handler
    @handler.num_columns { |_, _| 3 }
    @handler.column_type { |_, _, _| UIng::TableValueType::String }
    @handler.num_rows { |_, _| MD5Checker.instance.result_count }
    @handler.cell_value { |_, _, row, column|
      value = MD5Checker.instance.result_at(row, column)
      UIng.new_table_value_string(value).to_unsafe
    }
    @handler.set_cell_value { |_, _, _, _, _| Void }
  end
end
