require "../spec_helper"
require "../support/table_models"

private class TableSchemaTable < UIng::Table
  def initialize(model : UIng::Table::Model)
    @ref_ptr = Pointer(UIng::LibUI::Table).null
    @table_model_ref = model
  end
end

describe UIng::Table do
  it "validates every table display-column role before calling libui" do
    types = [UIng::Table::Value::Type::String, UIng::Table::Value::Type::Image, UIng::Table::Value::Type::Int, UIng::Table::Value::Type::Color]
    model = SpecSupport::TableSchemaModel.new(types)
    table = TableSchemaTable.new(model)

    expect_raises(ArgumentError, /text.*expected String, got Int/) do
      table.append_text_column("text", 2, UIng::Table::ModelColumn::Never)
    end
    expect_raises(ArgumentError, /image.*expected Image, got String/) do
      table.append_image_column("image", 0)
    end
    expect_raises(ArgumentError, /checkbox.*expected Int, got String/) do
      table.append_checkbox_column("checkbox", 0, UIng::Table::ModelColumn::Never)
    end
    expect_raises(ArgumentError, /progress.*expected Int, got String/) do
      table.append_progress_bar_column("progress", 0)
    end
    expect_raises(ArgumentError, /button.*expected String, got Int/) do
      table.append_button_column("button", 2, UIng::Table::ModelColumn::Always)
    end
    expect_raises(ArgumentError, /text color.*expected Color, got Image/) do
      table.append_text_column("color", 0, UIng::Table::ModelColumn::Never, 1)
    end
  end
end
