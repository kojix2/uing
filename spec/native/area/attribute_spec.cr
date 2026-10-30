require "../../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Area::Attribute do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "checks typed getters before reading native unions" do
      family_attribute = UIng::Area::Attribute.new_family("Sans")
      size_attribute = UIng::Area::Attribute.new_size(12.0)
      weight_attribute = UIng::Area::Attribute.new_weight(UIng::TextWeight::Bold)
      italic_attribute = UIng::Area::Attribute.new_italic(UIng::TextItalic::Italic)
      stretch_attribute = UIng::Area::Attribute.new_stretch(UIng::TextStretch::Expanded)
      color_attribute = UIng::Area::Attribute.new_color(0.1, 0.2, 0.3, 1.0)
      background_attribute = UIng::Area::Attribute.new_background(0.4, 0.5, 0.6, 1.0)
      underline_attribute = UIng::Area::Attribute.new_underline(UIng::Area::Attribute::Underline::Double)
      underline_color_attribute = UIng::Area::Attribute.new_underline_color(
        UIng::Area::Attribute::UnderlineColor::Custom,
        0.2, 0.4, 0.6, 1.0
      )

      family_attribute.family.should eq("Sans")
      size_attribute.size.should eq(12.0)
      weight_attribute.weight.should eq(UIng::TextWeight::Bold)
      italic_attribute.italic.should eq(UIng::TextItalic::Italic)
      stretch_attribute.stretch.should eq(UIng::TextStretch::Expanded)
      color_attribute.color.should eq({0.1, 0.2, 0.3, 1.0})
      background_attribute.color.should eq({0.4, 0.5, 0.6, 1.0})
      underline_attribute.underline.should eq(UIng::Area::Attribute::Underline::Double)
      underline_color_attribute.underline_color.should eq({
        UIng::Area::Attribute::UnderlineColor::Custom,
        0.2, 0.4, 0.6, 1.0,
      })

      expect_raises(TypeCastError, /expected Family, got Size/) { size_attribute.family }
    ensure
      family_attribute.try &.free
      size_attribute.try &.free
      weight_attribute.try &.free
      italic_attribute.try &.free
      stretch_attribute.try &.free
      color_attribute.try &.free
      background_attribute.try &.free
      underline_attribute.try &.free
      underline_color_attribute.try &.free
    end

    it "keeps extracted features independent of the source and Attribute lifetime" do
      source_features = UIng::OpenTypeFeatures.new
      source_features.add("liga", 3_u32)
      features_attribute = UIng::Area::Attribute.new_features(source_features)
      cloned_features = features_attribute.features

      cloned_features.get("liga").should eq(3_u32)
      source_features.add("liga", 0_u32)
      features_attribute.free
      GC.collect
      cloned_features.get("liga").should eq(3_u32)
    ensure
      features_attribute.try &.free
    end

    it "rejects every Attribute operation after free" do
      attribute = UIng::Area::Attribute.new_size(12)
      attribute.free

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
    ensure
      attribute.try &.free
    end

    it "rejects a borrowed Attribute after its callback ends" do
      UIng::Area::AttributedString.open("abc") do |string|
        string.set_attribute(UIng::Area::Attribute.new_size(12), 0, 3)
        borrowed : UIng::Area::Attribute? = nil
        string.each_attribute do |attribute, _start, _end|
          attribute.released?.should be_false
          attribute.size.should eq(12.0)
          borrowed = attribute
        end

        attribute = borrowed.should_not be_nil
        attribute.released?.should be_true
        expect_raises(Exception, /already been released/) { attribute.to_unsafe }
        string.string.should eq("abc")
      end
    end
  end
{% end %}
