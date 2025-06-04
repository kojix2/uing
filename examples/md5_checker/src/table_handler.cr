require "uing"
require "./checker"

# Table model handler for MD5 checker
class MD5TableHandler
  def initialize
    @handler = UIng::TableModelHandler.new do
      num_columns { |_, _| 3 }
      column_type { |_, _, _| UIng::TableValueType::String }
      num_rows { |_, _| MD5Checker.instance.result_count }
      cell_value { |_, _, row, column|
        value = MD5Checker.instance.result_at(row, column)
        UIng::TableValue.new(value).to_unsafe
      }
      set_cell_value { |_, _, _, _, _| Void }
    end
  end

  # Get the underlying handler
  def handler
    @handler
  end

  # Create a table model
  def create_model
    UIng::TableModel.new(@handler)
  end
end
