require "../../spec_helper"
require "../../support/table_models"

private class LifetimeSafetyTable < UIng::Table
  def initialize(model : UIng::Table::Model)
    @ref_ptr = Pointer(UIng::LibUI::Table).null
    @table_model_ref = model
    model.register(self)
  end

  def release_for_spec : Nil
    after_destroy
  end

  protected def destroy_native : Nil
  end
end

describe UIng::Table::Model do
  it "prevents freeing a model while a registered Table is alive" do
    model = SpecSupport::LifetimeSafetyModel.new
    table = LifetimeSafetyTable.new(model)

    model.tracked_table_count.should eq(1)
    expect_raises(Exception, /still used by a Table/) { model.free }

    table.release_for_spec
    model.tracked_table_count.should eq(0)
    model.free
    model.native_freed?.should be_true
  end

  it "defers native model free until its DestroyPending Table is destroyed" do
    model = SpecSupport::LifetimeSafetyModel.new
    table = LifetimeSafetyTable.new(model)

    table.destroy
    model.free

    model.native_freed?.should be_false
    model.tracked_table_count.should eq(1)
    expect_raises(Exception, /already been released/) { model.to_unsafe }

    table.release_for_spec
    model.native_freed?.should be_true
    model.tracked_table_count.should eq(0)
  end

  it "defers native model free until all DestroyPending Tables are destroyed" do
    model = SpecSupport::LifetimeSafetyModel.new
    first = LifetimeSafetyTable.new(model)
    second = LifetimeSafetyTable.new(model)

    first.destroy
    second.destroy
    model.free
    model.free

    first.release_for_spec
    model.native_freed?.should be_false
    model.tracked_table_count.should eq(1)

    second.release_for_spec
    model.native_freed?.should be_true
    model.tracked_table_count.should eq(0)
  end

  it "accepts data, state, and optional color columns with matching types" do
    types = [UIng::Table::Value::Type::String, UIng::Table::Value::Type::Image, UIng::Table::Value::Type::Int, UIng::Table::Value::Type::Color]
    model = SpecSupport::TableSchemaModel.new(types)

    types.each_with_index { |type, column| model.validate_data(column, type) }
    model.validate_state(UIng::Table::ModelColumn::Never.value)
    model.validate_state(UIng::Table::ModelColumn::Always.value)
    model.validate_state(2)
    model.validate_color(-1)
    model.validate_color(3)
  end

  it "rejects out-of-range columns, invalid special values, and type mismatches" do
    types = [UIng::Table::Value::Type::String, UIng::Table::Value::Type::Image, UIng::Table::Value::Type::Int, UIng::Table::Value::Type::Color]
    model = SpecSupport::TableSchemaModel.new(types)

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

  it "makes schema bypass explicit for wrapped native models" do
    model = UIng::Table::Model.unsafe_wrap(Pointer(UIng::LibUI::TableModel).new(0x230_u64))
    params = UIng::Table::Params.new(model, -123)

    params.model.should be(model)
    params.row_background_color_model_column.should eq(-123)
  end
end
