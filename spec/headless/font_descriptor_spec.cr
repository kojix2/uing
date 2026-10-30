require "../spec_helper"

describe UIng::FontDescriptor do
  it "rejects zero font size" do
    expect_raises(ArgumentError, /font descriptor size must be finite and positive/) do
      UIng::FontDescriptor.new(
        family: "Inter",
        size: 0,
        weight: UIng::TextWeight::Normal,
        italic: UIng::TextItalic::Normal,
        stretch: UIng::TextStretch::Normal
      )
    end
  end

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
end
