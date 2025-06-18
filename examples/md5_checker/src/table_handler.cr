require "uing"
require "./checker"

# Table model handler for MD5 checker
class MD5TableHandler
  def initialize
    @handler = UIng::Table::Model::Handler.new do
      num_columns { 3 }
      column_type { |i| UIng::Table::Value::Type::String }
      num_rows { MD5Checker.instance.result_count }
      cell_value { |row, column|
        value = MD5Checker.instance.result_at(row, column)
        UIng::Table::Value.new(value)
      }
      set_cell_value { |row, column, value| }
    end
  end

  # Get the underlying handler
  def handler
    @handler
  end

  # Create a table model
  def create_model
    UIng::Table::Model.new(@handler)
  end
end
