require "./spec_helper"

# Replace the two native lifecycle calls in this spec process so the block
# overload can be exercised without opening a platform UI session.
module UIng
  @@lifetime_safety_init_calls = 0
  @@lifetime_safety_uninit_calls = 0

  def self.init : Nil
    @@lifetime_safety_init_calls += 1
  end

  def self.uninit : Nil
    @@lifetime_safety_uninit_calls += 1
  end

  def self.reset_lifetime_safety_init_calls : Nil
    @@lifetime_safety_init_calls = 0
    @@lifetime_safety_uninit_calls = 0
  end

  def self.lifetime_safety_init_calls : Int32
    @@lifetime_safety_init_calls
  end

  def self.lifetime_safety_uninit_calls : Int32
    @@lifetime_safety_uninit_calls
  end
end

private class LifetimeSafetyMenuItem < UIng::MenuItem
  getter callback_was_retained_when_cleared = false

  def initialize
    super(Pointer(UIng::LibUI::MenuItem).null)
    @on_clicked_box = Pointer(Void).new(1_u64)
  end

  private def clear_native_callback : Nil
    @callback_was_retained_when_cleared = !@on_clicked_box.nil?
  end
end

private class ReleasedLifetimeSafetySelection < UIng::Table::Selection
  def initialize
    super([1])
    @released = true
  end
end

private class LifetimeSafetyModel < UIng::Table::Model
  def initialize
    super(Pointer(UIng::LibUI::TableModel).null)
  end

  def tracked_table_count : Int32
    @tables.size
  end
end

private class LifetimeSafetyTable < UIng::Table
  def initialize(model : UIng::Table::Model)
    @ref_ptr = Pointer(UIng::LibUI::Table).null
    @table_model_ref = model
    model.register(self)
  end

  def release_for_spec : Nil
    mark_released_from_parent_destroy
  end
end

describe "lifetime safety" do
  it "rejects every Table::Selection pointer read after free" do
    selection = ReleasedLifetimeSafetySelection.new

    expect_raises(Exception, /already been released/) { selection.num_rows }
    expect_raises(Exception, /already been released/) { selection.rows }
    expect_raises(Exception, /already been released/) { selection.rows_ptr }
  end

  it "uninitializes UIng when its init block raises" do
    UIng.reset_lifetime_safety_init_calls

    expect_raises(Exception, "boom") do
      UIng.init { raise "boom" }
    end

    UIng.lifetime_safety_init_calls.should eq(1)
    UIng.lifetime_safety_uninit_calls.should eq(1)
  end

  it "clears the native MenuItem callback before releasing its callback box" do
    item = LifetimeSafetyMenuItem.new

    item.destroy

    item.callback_was_retained_when_cleared.should be_true
  end

  it "prevents freeing a model while a registered Table is alive" do
    model = LifetimeSafetyModel.new
    table = LifetimeSafetyTable.new(model)

    model.tracked_table_count.should eq(1)
    expect_raises(Exception, /still used by a Table/) { model.free }

    table.release_for_spec
    model.tracked_table_count.should eq(0)
  end
end
