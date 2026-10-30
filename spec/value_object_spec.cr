require "./spec_helper"

describe "public value objects" do
  it "configures FontDescriptor through its block and preserves the instance" do
    yielded = nil
    font = UIng::FontDescriptor.new(
      family: "Inter", size: 14, weight: UIng::TextWeight::Normal,
      italic: UIng::TextItalic::Normal, stretch: UIng::TextStretch::Normal
    ) do |descriptor|
      yielded = descriptor
      family.should eq("Inter")
      descriptor.size = 18
      descriptor.weight = :bold
      :ignored
    end

    font.should be(yielded)
    font.size.should eq(18)
    font.weight.should eq(UIng::TextWeight::Bold)
  end

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

    descriptor.size = 16.5
    descriptor.size.should eq(16.5)
    descriptor.weight = :normal
    descriptor.italic = :oblique
    descriptor.stretch = :expanded
    descriptor.weight.should eq(UIng::TextWeight::Normal)
    descriptor.italic.should eq(UIng::TextItalic::Oblique)
    descriptor.stretch.should eq(UIng::TextStretch::Expanded)
    String.new(descriptor.to_unsafe.value.family).should eq("Inter")

    descriptor.family = "Other"
    String.new(descriptor.to_unsafe.value.family).should eq("Other")
  end

  it "keeps a FontDescriptor snapshot valid independently" do
    descriptor = UIng::FontDescriptor.new(
      family: "Inter",
      size: 14.5,
      weight: UIng::TextWeight::Bold,
      italic: UIng::TextItalic::Italic,
      stretch: UIng::TextStretch::Normal
    )
    snapshot = descriptor.snapshot

    descriptor.family = "Changed"
    descriptor.size = 20

    snapshot.family.should eq("Inter")
    snapshot.size.should eq(14.5)
    snapshot.weight.should eq(UIng::TextWeight::Bold)
    snapshot.italic.should eq(UIng::TextItalic::Italic)
    snapshot.stretch.should eq(UIng::TextStretch::Normal)
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
