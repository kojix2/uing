require "./spec_helper"

private struct FakeTableValue
  getter type : UIng::Table::Value::Type

  def initialize(@type : UIng::Table::Value::Type)
  end
end

private def call_set_cell_value(
  handler : UIng::Table::Model::Handler,
  row : Int32,
  column : Int32,
  value : Pointer(UIng::LibUI::TableValue),
) : Nil
  handler_ptr = handler.to_unsafe
  handler_ptr.value.set_cell_value.call(
    handler_ptr,
    Pointer(UIng::LibUI::TableModel).null,
    row,
    column,
    value
  )
end

private def call_cell_value(
  handler : UIng::Table::Model::Handler,
  row : Int32,
  column : Int32,
) : Pointer(UIng::LibUI::TableValue)
  handler_ptr = handler.to_unsafe
  handler_ptr.value.cell_value.call(
    handler_ptr,
    Pointer(UIng::LibUI::TableModel).null,
    row,
    column
  )
end

private def call_column_type(
  handler : UIng::Table::Model::Handler,
  column : Int32,
) : UIng::Table::Value::Type
  handler_ptr = handler.to_unsafe
  handler_ptr.value.column_type.call(
    handler_ptr,
    Pointer(UIng::LibUI::TableModel).null,
    column
  )
end

describe UIng::Table::Model::Handler do
  it "passes a NULL set-cell value to the callback as nil" do
    received = nil
    handler = UIng::Table::Model::Handler.new
    handler.set_cell_value do |row, column, value|
      received = {row, column, value}
    end

    call_set_cell_value(handler, 2, 3, Pointer(UIng::LibUI::TableValue).null)

    received.should eq({2, 3, nil})
  end

  it "wraps a non-NULL set-cell value as borrowed" do
    value_ptr = Pointer(UIng::LibUI::TableValue).new(0x200_u64)
    received_value = nil
    handler = UIng::Table::Model::Handler.new
    handler.set_cell_value do |_row, _column, value|
      received_value = value
    end

    call_set_cell_value(handler, 0, 0, value_ptr)

    value = received_value.should_not be_nil
    value.borrowed?.should be_true
    value.to_unsafe.should eq(value_ptr)
  end

  it "returns NULL when the cell-value callback returns nil" do
    handler = UIng::Table::Model::Handler.new
    handler.column_type { |_column| UIng::Table::Value::Type::Color }
    handler.cell_value { |_row, _column| nil }

    call_cell_value(handler, 0, 0).null?.should be_true
  end

  it "returns values matching all declared column types" do
    types = [
      UIng::Table::Value::Type::String,
      UIng::Table::Value::Type::Image,
      UIng::Table::Value::Type::Int,
      UIng::Table::Value::Type::Color,
    ]
    native_values = types.map { |type| FakeTableValue.new(type) }
    values = types.each_index.map do |index|
      ptr = (native_values.to_unsafe + index).as(Pointer(UIng::LibUI::TableValue))
      UIng::Table::Value.new(ptr, borrowed: false)
    end.to_a
    handler = UIng::Table::Model::Handler.new
    handler.column_type { |column| types[column] }
    handler.cell_value { |_row, column| values[column] }

    types.each_with_index do |expected_type, column|
      value_ptr = call_cell_value(handler, 0, column)
      value_ptr.null?.should be_false
      UIng::LibUI.table_value_get_type(value_ptr).should eq(expected_type)
    end
  end

  it "caches each declared column type" do
    calls = 0
    declared_type = UIng::Table::Value::Type::Int
    handler = UIng::Table::Model::Handler.new
    handler.column_type do |_column|
      calls += 1
      declared_type
    end

    call_column_type(handler, 0).should eq(UIng::Table::Value::Type::Int)
    declared_type = UIng::Table::Value::Type::String
    call_column_type(handler, 0).should eq(UIng::Table::Value::Type::Int)
    calls.should eq(1)

    expect_raises(Exception, /Cannot change table column types/) do
      handler.column_type { |_column| UIng::Table::Value::Type::Color }
    end
  end
end
