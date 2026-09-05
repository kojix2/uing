require "./spec_helper"

private class TableSchemaModel < UIng::Table::Model
  def initialize(column_types : Array(UIng::Table::Value::Type))
    super(Pointer(UIng::LibUI::TableModel).null)
    @column_types = column_types
  end

  def validate_data(column : Int32, type : UIng::Table::Value::Type, role : String = "data") : Nil
    validate_data_column(column, type, role)
  end

  def validate_state(column : Int32) : Nil
    validate_state_column(column, "state")
  end

  def validate_color(column : Int32) : Nil
    validate_optional_color_column(column, "color")
  end
end

private class TableSchemaTable < UIng::Table
  def initialize(model : UIng::Table::Model)
    @ref_ptr = Pointer(UIng::LibUI::Table).null
    @table_model_ref = model
  end
end

describe "Table model schema validation" do
  types = [
    UIng::Table::Value::Type::String,
    UIng::Table::Value::Type::Image,
    UIng::Table::Value::Type::Int,
    UIng::Table::Value::Type::Color,
  ]

  it "accepts data, state, and optional color columns with matching types" do
    model = TableSchemaModel.new(types)

    types.each_with_index { |type, column| model.validate_data(column, type) }
    model.validate_state(UIng::Table::ModelColumn::Never.value)
    model.validate_state(UIng::Table::ModelColumn::Always.value)
    model.validate_state(2)
    model.validate_color(-1)
    model.validate_color(3)
  end

  it "rejects out-of-range columns, invalid special values, and type mismatches" do
    model = TableSchemaModel.new(types)

    expect_raises(ArgumentError, /column -1 is out of range/) do
      model.validate_data(-1, UIng::Table::Value::Type::String)
    end
    expect_raises(ArgumentError, /column 4 is out of range/) do
      model.validate_data(4, UIng::Table::Value::Type::String)
    end
    expect_raises(ArgumentError, /expected String, got Int/) do
      model.validate_data(2, UIng::Table::Value::Type::String)
    end
    expect_raises(ArgumentError, /column -3 is out of range/) { model.validate_state(-3) }
    expect_raises(ArgumentError, /expected Int, got String/) { model.validate_state(0) }
    expect_raises(ArgumentError, /column -2 is out of range/) { model.validate_color(-2) }
    expect_raises(ArgumentError, /expected Color, got Image/) { model.validate_color(1) }
  end

  it "validates every table display-column role before calling libui" do
    model = TableSchemaModel.new(types)
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

  it "makes schema bypass explicit for wrapped native models" do
    model = UIng::Table::Model.unsafe_wrap(Pointer(UIng::LibUI::TableModel).new(0x230_u64))
    params = UIng::Table::Params.new(model, -123)

    params.model.should be(model)
    params.row_background_color_model_column.should eq(-123)
  end
end
