require "./spec_helper"

describe "public value objects" do
  it "maps FontDescriptor properties without native allocation" do
    descriptor = UIng::FontDescriptor.new(
      family: "Inter",
      size: 14,
      weight: UIng::TextWeight::Bold,
      italic: UIng::TextItalic::Italic,
      stretch: UIng::TextStretch::Normal
    )

    descriptor.family.should eq("Inter")
    descriptor.size.should eq(14)
    descriptor.weight.should eq(UIng::TextWeight::Bold)
    descriptor.italic.should eq(UIng::TextItalic::Italic)
    descriptor.stretch.should eq(UIng::TextStretch::Normal)
  ensure
    descriptor.try &.free
  end

  it "keeps a FontDescriptor snapshot valid independently" do
    descriptor = UIng::FontDescriptor.new(
      family: "Inter",
      size: 14,
      weight: UIng::TextWeight::Bold,
      italic: UIng::TextItalic::Italic,
      stretch: UIng::TextStretch::Normal
    )
    snapshot = descriptor.snapshot

    descriptor.family = "Changed"
    descriptor.size = 20
    descriptor.free

    snapshot.family.should eq("Inter")
    snapshot.size.should eq(14)
    snapshot.weight.should eq(UIng::TextWeight::Bold)
    snapshot.italic.should eq(UIng::TextItalic::Italic)
    snapshot.stretch.should eq(UIng::TextStretch::Normal)
  ensure
    descriptor.try &.free
    snapshot.try &.free
  end

  it "rejects FontDescriptor access after release" do
    descriptor = UIng::FontDescriptor.new(
      family: "Inter",
      size: 14,
      weight: UIng::TextWeight::Bold,
      italic: UIng::TextItalic::Italic,
      stretch: UIng::TextStretch::Normal
    )
    descriptor.free

    descriptor.released?.should be_true
    expect_raises(Exception, /already been released/) { descriptor.family }
    expect_raises(Exception, /already been released/) { descriptor.family = "Other" }
    expect_raises(Exception, /already been released/) { descriptor.size }
    expect_raises(Exception, /already been released/) { descriptor.size = 16 }
    expect_raises(Exception, /already been released/) { descriptor.weight }
    expect_raises(Exception, /already been released/) { descriptor.weight = UIng::TextWeight::Normal }
    expect_raises(Exception, /already been released/) { descriptor.italic }
    expect_raises(Exception, /already been released/) { descriptor.italic = UIng::TextItalic::Normal }
    expect_raises(Exception, /already been released/) { descriptor.stretch }
    expect_raises(Exception, /already been released/) { descriptor.stretch = UIng::TextStretch::Normal }
    expect_raises(Exception, /already been released/) { descriptor.snapshot }
    expect_raises(Exception, /already been released/) { descriptor.to_unsafe }
  ensure
    descriptor.try &.free
  end

  it "keeps Table::Params model and row-color fields synchronized" do
    first = UIng::Table::Model.unsafe_wrap(Pointer(UIng::LibUI::TableModel).new(0x210_u64))
    second = UIng::Table::Model.unsafe_wrap(Pointer(UIng::LibUI::TableModel).new(0x220_u64))
    params = UIng::Table::Params.new(first, 3)

    params.model.should be(first)
    params.row_background_color_model_column.should eq(3)

    params.model = second
    params.row_background_color_model_column = 5

    params.model.should be(second)
    params.to_unsafe.value.model.should eq(second.to_unsafe)
    params.to_unsafe.value.row_background_color_model_column.should eq(5)
  end

  it "keeps optional text-column parameters synchronized" do
    params = UIng::Table::TextColumnOptionalParams.new(2)
    params.color_model_column.should eq(2)

    params.color_model_column = 4

    params.color_model_column.should eq(4)
    params.to_unsafe.value.color_model_column.should eq(4)
  end
end
