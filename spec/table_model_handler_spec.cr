require "./spec_helper"

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
    handler.cell_value { |_row, _column| nil }

    call_cell_value(handler, 0, 0).null?.should be_true
  end
end
