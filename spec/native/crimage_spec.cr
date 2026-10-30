require "../spec_helper"
require "../../src/uing/crimage"
require "../support/toolbar_items"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe "CrImage integration" do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    describe "colors and images" do
      it "converts CrImage colors and images through native controls" do
        color = CrImage::Color::NRGBA.new(255, 0, 0, 128)
        foreground = UIng::Area::Attribute.new_color(color)
        background = UIng::Area::Attribute.new_background(color)
        underline = UIng::Area::Attribute.new_underline_color(UIng::Area::Attribute::UnderlineColor::Custom, color)
        table_color = UIng::Table::Value.new_color(color)

        foreground.color[0].should be_close(1.0, 1.0 / 255)
        background.color[3].should be_close(128.0 / 255, 1.0 / 255)
        underline.underline_color[1].should be_close(1.0, 1.0 / 255)
        table_color.color[3].should be_close(128.0 / 255, 1.0 / 255)

        color_button = UIng::ColorButton.new
        color_button.color = color
        color_button.color[0].should be_close(1.0, 1.0 / 255)
        color_button.color[3].should be_close(128.0 / 255, 1.0 / 255)
        color_button.color_crimage.should be_a(CrImage::Color::NRGBA)
        color_button.set_color(CrImage::Color::NRGBA.new(0, 255, 0, 255))
        color_button.color[1].should be_close(1.0, 1.0 / 255)

        source = CrImage::NRGBA.new(CrImage.rect(0, 0, 1, 1))
        source.set_nrgba(0, 0, color)
        image = source.to_uing_image
        image.append(CrImage.rgba(2, 2, color))
        file_image = UIng::Image.from_file(File.expand_path("../../examples/gallery/crys.png", __DIR__))
        view = UIng::ImageView.new(source)
        view.image = source
        view.image = nil

        window = UIng::Window.new("CrImage integration spec", 200, 100)
        box = UIng::Box.new(:vertical)
        box.append(color_button)
        box.append(view)
        window.child = box
      ensure
        window.try { |control| control.destroy unless control.released? }
        image.try &.free
        file_image.try &.free
        foreground.try &.free
        background.try &.free
        underline.try &.free
        table_color.try &.free
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
