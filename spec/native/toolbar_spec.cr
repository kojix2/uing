require "../spec_helper"

if ENV["UING_NATIVE_GUI_TESTS"]? == "1"
  describe "native toolbar display modes" do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "changes modes while attached and detached without replacing the public items" do
      window = UIng::Window.new("Toolbar modes", 400, 200)
      toolbar = UIng::Toolbar.new
      image = UIng::Image.new(16, 16)
      image.append(Bytes.new(16 * 16 * 4, 0xFF_u8), 16, 16, 16 * 4)
      item = toolbar.append_toggle_button("Pinned")
      button = toolbar.append_button("Action", image)
      item.checked = true
      item.disable
      item.tooltip = "Keep pinned"
      toolbar_ptr = toolbar.to_unsafe
      item_ptr = item.to_unsafe
      window.toolbar = toolbar

      UIng::Toolbar::DisplayMode.values.each do |from|
        UIng::Toolbar::DisplayMode.values.each do |to|
          toolbar.display_mode = from
          toolbar.display_mode = to
          toolbar.display_mode.should eq(to)
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
    ensure
      if window && !window.released?
        window.toolbar = nil
        window.destroy
      end
      toolbar.try &.free
      image.try &.free
    end
  end
end
