require "../../spec_helper"
require "../../support/native_wrappers"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Table::Value do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "checks typed getters before reading native unions" do
      int_value = UIng::Table::Value.new(7)
      string_value = UIng::Table::Value.new("seven")
      image_value = UIng::Table::Value.owned_from_native_for_spec(
        UIng::LibUI.new_table_value_image(Pointer(UIng::LibUI::Image).null)
      )
      table_color_value = UIng::Table::Value.new_color(0.7, 0.8, 0.9, 1.0)

      int_value.int.should eq(7)
      string_value.string.should eq("seven")
      image_value.image_pointer.null?.should be_true
      table_color_value.color.should eq({0.7, 0.8, 0.9, 1.0})

      expect_raises(TypeCastError, /expected String, got Int/) { int_value.string }
    ensure
      int_value.try &.free
      string_value.try &.free
      image_value.try &.free
      table_color_value.try &.free
    end
  end
{% end %}
