require "../../spec_helper"
require "../../support/native_wrappers"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Table::Value do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "checks typed TableValue and Attribute getters before reading native unions" do
      int_value = UIng::Table::Value.new(7)
      string_value = UIng::Table::Value.new("seven")
      image_value = UIng::Table::Value.owned_from_native_for_spec(
        UIng::LibUI.new_table_value_image(Pointer(UIng::LibUI::Image).null)
      )
      table_color_value = UIng::Table::Value.new_color(0.7, 0.8, 0.9, 1.0)
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
      source_features = UIng::OpenTypeFeatures.new
      source_features.add("liga", 3_u32)
      features_attribute = UIng::Area::Attribute.new_features(source_features)

      int_value.int.should eq(7)
      string_value.string.should eq("seven")
      image_value.image_pointer.null?.should be_true
      table_color_value.color.should eq({0.7, 0.8, 0.9, 1.0})
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
      cloned_features = features_attribute.features
      cloned_features.get("liga").should eq(3_u32)
      source_features.add("liga", 0_u32)
      features_attribute.free
      GC.collect
      cloned_features.get("liga").should eq(3_u32)

      expect_raises(TypeCastError, /expected String, got Int/) { int_value.string }
      expect_raises(TypeCastError, /expected Family, got Size/) { size_attribute.family }
    ensure
      int_value.try &.free
      string_value.try &.free
      image_value.try &.free
      table_color_value.try &.free
      family_attribute.try &.free
      size_attribute.try &.free
      weight_attribute.try &.free
      italic_attribute.try &.free
      stretch_attribute.try &.free
      color_attribute.try &.free
      background_attribute.try &.free
      underline_attribute.try &.free
      underline_color_attribute.try &.free
      features_attribute.try &.free
    end
  end
{% end %}
