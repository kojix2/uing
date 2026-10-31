require "../spec_helper"
require "../../src/uing/crimage"
require "../support/native_controls"
require "../support/toolbar_items"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe "CrImage integration" do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    describe "color conversion" do
      it "converts CrImage colors to foreground, background, and underline attributes" do
        color = CrImage::Color::NRGBA.new(255, 0, 0, 128)
        foreground = UIng::Area::Attribute.new_color(color)
        background = UIng::Area::Attribute.new_background(color)
        underline = UIng::Area::Attribute.new_underline_color(UIng::Area::Attribute::UnderlineColor::Custom, color)

        foreground.color[0].should be_close(1.0, 1.0 / 255)
        background.color[3].should be_close(128.0 / 255, 1.0 / 255)
        underline.underline_color[1].should be_close(1.0, 1.0 / 255)
      ensure
        foreground.try &.free
        background.try &.free
        underline.try &.free
      end

      it "converts a CrImage color to a table color value" do
        table_color = UIng::Table::Value.new_color(CrImage::Color::NRGBA.new(255, 0, 0, 128))

        table_color.color[3].should be_close(128.0 / 255, 1.0 / 255)
      ensure
        table_color.try &.free
      end

      it "reads and updates ColorButton colors through the CrImage API" do
        SpecSupport.with_native_control(UIng::ColorButton.new) do |button|
          button.color = CrImage::Color::NRGBA.new(255, 0, 0, 128)
          button.color[0].should be_close(1.0, 1.0 / 255)
          button.color[3].should be_close(128.0 / 255, 1.0 / 255)
          button.color_crimage.should be_a(CrImage::Color::NRGBA)
          button.set_color(CrImage::Color::NRGBA.new(0, 255, 0, 255))
          button.color[1].should be_close(1.0, 1.0 / 255)
        end
      end
    end

    describe "image conversion" do
      it "creates an Image from CrImage pixels and appends a higher-resolution representation" do
        color = CrImage::Color::NRGBA.new(255, 0, 0, 128)
        source = CrImage::NRGBA.new(CrImage.rect(0, 0, 1, 1))
        source.set_nrgba(0, 0, color)
        image = source.to_uing_image
        image.size.should eq({1.0, 1.0})

        image.append(CrImage.rgba(2, 2, color))
        image.size.should eq({1.0, 1.0})
      ensure
        image.try &.free
      end

      it "loads a native Image from a PNG file" do
        image = UIng::Image.from_file(File.expand_path("../../examples/gallery/crys.png", __DIR__))

        image.size.should eq({400.0, 400.0})
      ensure
        image.try &.free
      end
    end

    describe "image views" do
      it "accepts CrImage sources during construction, replacement, and clearing" do
        source = CrImage::NRGBA.new(CrImage.rect(0, 0, 1, 1))
        source.set_nrgba(0, 0, CrImage::Color::NRGBA.new(255, 0, 0, 128))

        SpecSupport.with_native_control(UIng::ImageView.new(source)) do |view|
          view.image = source
          view.image = nil
        end
      end
    end

    describe "toolbar icons" do
      it "copies CrImage icons for buttons, toggle buttons, and icon replacements" do
        toolbar = UIng::Toolbar.new
        source = CrImage.rgba(2, 3)
        button = toolbar.append_button("Action", source) do |item|
          item.tooltip = "CrImage action"
          on_clicked { |_clicked| }
        end
        toggle = toolbar.append_toggle_button("Pinned", source) do |item|
          item.checked = true
        end
        button.tooltip.should eq("CrImage action")
        first_icon = button.retained_icon_for_spec || raise "missing button icon"
        toggle_icon = toggle.retained_icon_for_spec || raise "missing toggle icon"
        first_icon.size.should eq({2.0, 3.0})
        toggle_icon.size.should eq({2.0, 3.0})
        toggle.checked = true
        toggle.checked?.should be_true

        replacement = CrImage::NRGBA.new(CrImage.rect(5, 7, 9, 12))
        button.icon = replacement
        expect_raises(Exception, /already been released/) { first_icon.to_unsafe }
        replacement_icon = button.retained_icon_for_spec || raise "missing replacement icon"
        replacement_icon.size.should eq({4.0, 5.0})
        button.icon = nil
        expect_raises(Exception, /already been released/) { replacement_icon.to_unsafe }
        toolbar.free
        expect_raises(Exception, /already been released/) { toggle_icon.to_unsafe }
        expect_raises(Exception, /already been released/) { button.icon = source }
        expect_raises(Exception, /already been released/) { toolbar.append_button("Late", source) }
      ensure
        toolbar.try &.free
      end
    end

    describe "conversion cleanup" do
      it "frees temporary native images when a CrImage conversion block raises" do
        temporary = nil
        expect_raises(Exception, "icon failure") do
          UIng::CrImageAdapter.with_image(CrImage.rgba(1, 1)) do |image|
            temporary = image
            raise "icon failure"
          end
        end
        image = temporary || raise "conversion block did not run"
        expect_raises(Exception, /already been released/) { image.to_unsafe }
      end
    end
  end
{% end %}
