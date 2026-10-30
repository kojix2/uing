require "../spec_helper"
require "../../src/uing/crimage"

class UIng::ToolbarItem
  def retained_icon_for_spec : UIng::Image?
    @icon_copy
  end
end

if ENV["UING_NATIVE_GUI_TESTS"]? == "1"
  describe "native toolbar display modes" do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "builds and attaches configured items through the block DSL" do
      window = UIng::Window.new("Toolbar DSL", 400, 200)
      image = UIng::Image.new(1, 1)
      image.append(Bytes[255, 255, 255, 255], 1, 1, 4)
      configured = nil
      button = nil
      toggle = nil
      window.toolbar do
        UIng::Toolbar.new do |bar|
          configured = bar
          button = append_button("Action", icon: image) do |item|
            item.tooltip = "Run action"
            disable
            on_clicked { |_clicked| }
            :ignored
          end
          toggle = append_toggle_button("Pinned") do |item|
            item.checked = true
          end
        end
      end
      image.free

      window.toolbar.should be(configured)
      configured_button = button.should_not be_nil
      configured_button.tooltip.should eq("Run action")
      configured_button.enabled?.should be_false
      toggle.should_not(be_nil).checked?.should be_true
      window.destroy
      configured.should_not(be_nil).released?.should be_true
      expect_raises(Exception, /already been released/) { configured_button.text }
    ensure
      window.try &.destroy
      image.try &.free
    end

    it "releases copied icons and items when a Toolbar configuration block raises" do
      window = UIng::Window.new("Failed Toolbar DSL", 400, 200)
      source = UIng::Image.new(1, 1)
      source.append(Bytes[255, 255, 255, 255], 1, 1, 4)
      constructed = nil
      configured_item = nil
      icon_copy = nil
      expect_raises(Exception, "configuration failed") do
        UIng::Toolbar.new do |bar|
          constructed = bar
          configured_item = append_button("Action", source) do |item|
            icon_copy = item.retained_icon_for_spec
            on_clicked { |_clicked| }
          end
          window.toolbar = bar
          raise "configuration failed"
        end
      end

      window.toolbar.should be_nil
      constructed.should_not(be_nil).released?.should be_true
      item = configured_item.should_not be_nil
      copied_icon = icon_copy.should_not be_nil
      expect_raises(Exception, /already been released/) { item.text }
      expect_raises(Exception, /already been released/) { copied_icon.to_unsafe }
    ensure
      window.try &.destroy
      source.try &.free
      constructed.try &.free
    end

    it "changes modes while attached and detached without replacing the public items" do
      window = UIng::Window.new("Toolbar modes", 400, 200)
      toolbar = UIng::Toolbar.new
      image = UIng::Image.new(16, 16)
      image.append(Bytes.new(16 * 16 * 4, 0xFF_u8), 16, 16, 16 * 4)
      item = toolbar.append_toggle_button("Pinned")
      button = toolbar.append_button("Action", image)
      image.free
      item.checked = true
      item.disable
      item.tooltip = "Keep pinned"
      toolbar_ptr = toolbar.to_unsafe
      item_ptr = item.to_unsafe
      window.toolbar = toolbar

      UIng::Toolbar::DisplayMode.values.each do |from|
        UIng::Toolbar::DisplayMode.values.each do |target_mode|
          toolbar.display_mode = from
          toolbar.display_mode = target_mode
          toolbar.display_mode.should eq(target_mode)
          toolbar.to_unsafe.should eq(toolbar_ptr)
          item.to_unsafe.should eq(item_ptr)
          item.text.should eq("Pinned")
          item.tooltip.should eq("Keep pinned")
          item.checked?.should be_true
          item.enabled?.should be_false
          button.text.should eq("Action")
        end
      end

      window.toolbar = nil
      toolbar.display_mode = UIng::Toolbar::DisplayMode::TextOnly
      window.toolbar = toolbar
      toolbar.display_mode.should eq(UIng::Toolbar::DisplayMode::TextOnly)
      expect_raises(Exception, /cannot be appended/) do
        toolbar.append_button("Late")
      end

      window.destroy
      toolbar.released?.should be_true
      expect_raises(Exception, /already been released/) { button.text }
    ensure
      window.try &.destroy
      toolbar.try &.free
      image.try &.free
    end

    it "copies replacement icons and preserves a toolbar detached before window destruction" do
      window = UIng::Window.new("Toolbar ownership", 400, 200)
      toolbar = UIng::Toolbar.new
      image = UIng::Image.new(16, 16)
      image.append(Bytes.new(16 * 16 * 4, 0xFF_u8), 16, 16, 16 * 4)
      item = toolbar.append_button("Action", image)
      item.icon = image
      image.free
      window.toolbar = toolbar
      item.icon = nil
      window.toolbar = nil
      window.destroy

      toolbar.released?.should be_false
      item.text.should eq("Action")
      toolbar.free
      expect_raises(Exception, /already been released/) { item.text }
    ensure
      window.try &.destroy
      toolbar.try &.free
      image.try &.free
    end

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
