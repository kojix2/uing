require "./spec_helper"

private class BoundaryAttributedString < UIng::Area::AttributedString
  def initialize(@contents : String)
    super(Pointer(UIng::LibUI::AttributedString).null)
  end

  def free : Nil
  end

  protected def native_len : LibC::SizeT
    LibC::SizeT.new(@contents.bytesize)
  end

  protected def native_string : Pointer(LibC::Char)
    @contents.to_unsafe
  end
end

private class BoundaryAttribute < UIng::Area::Attribute
  def initialize
    super(Pointer(UIng::LibUI::Attribute).null)
  end

  def free : Nil
    @released = true
  end
end

describe UIng::Area::AttributedString do
  it "rejects insertion positions outside the string or inside a UTF-8 codepoint" do
    string = BoundaryAttributedString.new("Aé🙂B")

    expect_raises(ArgumentError, /insertion position is out of bounds/) do
      string.insert_at_unattributed("x", 9)
    end
    expect_raises(ArgumentError, /insertion position is not on a UTF-8 codepoint boundary/) do
      string.insert_at_unattributed("x", 2)
    end
  end

  it "rejects invalid deletion ranges and identifies the invalid endpoint" do
    string = BoundaryAttributedString.new("Aé🙂B")

    expect_raises(ArgumentError, /deletion range start is after its end/) { string.delete(3, 1) }
    expect_raises(ArgumentError, /deletion range is out of bounds/) { string.delete(0, 9) }
    expect_raises(ArgumentError, /deletion range start is not on a UTF-8/) { string.delete(2, 3) }
    expect_raises(ArgumentError, /deletion range end is not on a UTF-8/) { string.delete(1, 2) }
  end

  it "rejects invalid attribute ranges before inspecting or transferring the Attribute" do
    string = BoundaryAttributedString.new("Aé🙂B")
    attribute = BoundaryAttribute.new

    expect_raises(ArgumentError, /attribute range start is not on a UTF-8/) do
      string.set_attribute(attribute, 2, 3)
    end

    attribute.released?.should be_false
  end

  it "validates byte and grapheme conversion positions" do
    string = BoundaryAttributedString.new("Aé🙂B")

    expect_raises(ArgumentError, /byte index is out of bounds/) { string.byte_index_to_grapheme(9) }
    expect_raises(ArgumentError, /byte index is not on a UTF-8/) { string.byte_index_to_grapheme(2) }
  end
end
