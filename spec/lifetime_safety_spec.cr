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

private class ReleasedLifetimeSafetyAttribute < UIng::Area::Attribute
  def initialize
    super(Pointer(UIng::LibUI::Attribute).null)
    self.released = true
  end
end

private class ReleasedLifetimeSafetyAttributedString < UIng::Area::AttributedString
  def initialize
    super(Pointer(UIng::LibUI::AttributedString).null)
    @released = true
  end
end

private class ReleasedLifetimeSafetyOpenTypeFeatures < UIng::OpenTypeFeatures
  def initialize
    super(Pointer(UIng::LibUI::OpenTypeFeatures).null)
    @released = true
  end
end

private class ReleasedLifetimeSafetyTextLayout < UIng::Area::Draw::TextLayout
  def initialize
    @ref_ptr = Pointer(UIng::LibUI::DrawTextLayout).null
    @released = true
  end
end

private class LifetimeSafetyModel < UIng::Table::Model
  getter native_freed = false

  def initialize
    super(Pointer(UIng::LibUI::TableModel).null)
  end

  def tracked_table_count : Int32
    @tables.size
  end

  protected def free_native : Nil
    @native_freed = true
  end
end

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

describe "lifetime safety" do
  it "rejects every Table::Selection pointer read after free" do
    selection = ReleasedLifetimeSafetySelection.new

    expect_raises(Exception, /already been released/) { selection.num_rows }
    expect_raises(Exception, /already been released/) { selection.rows }
    expect_raises(Exception, /already been released/) { selection.rows_ptr }
  end

  it "rejects every Attribute operation after free" do
    attribute = ReleasedLifetimeSafetyAttribute.new

    expect_raises(Exception, /already been released/) { attribute.type }
    expect_raises(Exception, /already been released/) { attribute.family }
    expect_raises(Exception, /already been released/) { attribute.size }
    expect_raises(Exception, /already been released/) { attribute.weight }
    expect_raises(Exception, /already been released/) { attribute.italic }
    expect_raises(Exception, /already been released/) { attribute.stretch }
    expect_raises(Exception, /already been released/) { attribute.color }
    expect_raises(Exception, /already been released/) { attribute.underline }
    expect_raises(Exception, /already been released/) { attribute.underline_color }
    expect_raises(Exception, /already been released/) { attribute.features }
    expect_raises(Exception, /already been released/) { attribute.to_unsafe }
  end

  it "rejects every AttributedString operation after free" do
    string = ReleasedLifetimeSafetyAttributedString.new
    attribute = ReleasedLifetimeSafetyAttribute.new

    expect_raises(Exception, /already been released/) { string.string }
    expect_raises(Exception, /already been released/) { string.len }
    expect_raises(Exception, /already been released/) { string.append_unattributed("x") }
    expect_raises(Exception, /already been released/) { string.insert_at_unattributed("x", 0) }
    expect_raises(Exception, /already been released/) { string.delete(0, 0) }
    expect_raises(Exception, /already been released/) { string.set_attribute(attribute, 0, 0) }
    expect_raises(Exception, /already been released/) do
      string.for_each_attribute { |_attribute, _start, _end| 0_i32 }
    end
    expect_raises(Exception, /already been released/) { string.num_graphemes }
    expect_raises(Exception, /already been released/) { string.byte_index_to_grapheme(0) }
    expect_raises(Exception, /already been released/) { string.grapheme_to_byte_index(0) }
    expect_raises(Exception, /already been released/) { string.to_unsafe }
  end

  it "rejects every OpenTypeFeatures operation after free" do
    features = ReleasedLifetimeSafetyOpenTypeFeatures.new

    expect_raises(Exception, /already been released/) { features.clone }
    expect_raises(Exception, /already been released/) { features.add("liga") }
    expect_raises(Exception, /already been released/) { features.remove("liga") }
    expect_raises(Exception, /already been released/) { features.get("liga") }
    expect_raises(Exception, /already been released/) do
      features.for_each { |_tag, _value| }
    end
    expect_raises(Exception, /already been released/) { features.to_unsafe }
  end

  it "rejects every TextLayout operation after free" do
    layout = ReleasedLifetimeSafetyTextLayout.new

    expect_raises(Exception, /already been released/) { layout.extents }
    expect_raises(Exception, /already been released/) { layout.to_unsafe }
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
    model.free
    model.native_freed.should be_true
  end

  it "allows model free immediately after its Table becomes DestroyPending" do
    model = LifetimeSafetyModel.new
    table = LifetimeSafetyTable.new(model)

    table.destroy
    model.free

    model.native_freed.should be_true
    model.tracked_table_count.should eq(1)
    expect_raises(Exception, /already been released/) { model.to_unsafe }

    table.release_for_spec
    model.tracked_table_count.should eq(0)
  end
end
