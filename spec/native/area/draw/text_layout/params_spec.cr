require "../../../../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Area::Draw::TextLayout::Params do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "keeps a valid replacement and its native pointer synchronized" do
      original = UIng::Area::AttributedString.new("original")
      replacement = UIng::Area::AttributedString.new("replacement")
      font = UIng::FontDescriptor.new
      params = UIng::Area::Draw::TextLayout::Params.new(
        string: original, default_font: font, width: 100, align: :left)

      params.string = replacement
      original.free

      params.string.should be(replacement)
      params.to_unsafe.value.string.should eq(replacement.to_unsafe)
      params.string.string.should eq("replacement")
    ensure
      replacement.try &.free
      original.try &.free
    end

    it "preserves the string and native pointer when a replacement has been freed" do
      original = UIng::Area::AttributedString.new("original")
      replacement = UIng::Area::AttributedString.new("replacement")
      font = UIng::FontDescriptor.new
      params = UIng::Area::Draw::TextLayout::Params.new(
        string: original, default_font: font, width: 100, align: :left)
      original_ptr = original.to_unsafe
      replacement.free

      expect_raises(Exception, /already been released/) { params.string = replacement }

      params.string.should be(original)
      params.to_unsafe.value.string.should eq(original_ptr)
      params.string.string.should eq("original")
    ensure
      replacement.try &.free
      original.try &.free
    end
  end
{% end %}
