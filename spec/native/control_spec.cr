require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  private def pointer_is_unavailable?(control : UIng::Control) : Bool
    control.to_unsafe
    false
  rescue
    true
  end

  private class NativeLifecycleWindow < UIng::Window
    block_constructor

    getter? native_destroyed = false

    def initialize(title, width, height)
      super(title, width, height)
    end

    protected def after_destroy : Nil
      @native_destroyed = true
      super
    end
  end

  private class NativeFailingAfterDestroyButton < UIng::Button
    getter? after_destroy_called = false

    def initialize
      super("Failing after_destroy")
    end

    def state_name : String
      lifecycle_state.to_s
    end

    protected def after_destroy : Nil
      super
      @after_destroy_called = true
      raise "native after_destroy failed"
    end
  end

  describe UIng::Control do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    describe "common control operations" do
      it "operates on mixed native controls through their common Control methods" do
        window = UIng::Window.new("Mixed controls spec", 320, 200)
        box = UIng::Box.new(:vertical)
        button = UIng::Button.new("Button")
        checkbox = UIng::Checkbox.new("Checkbox")
        entry = UIng::Entry.new
        box.append(button)
        box.append(checkbox)
        box.append(entry)
        window.child = box

        controls = [button, checkbox, entry]
        controls.each do |control|
          control.disable
          control.enabled?.should be_false
          control.enable
          control.enabled?.should be_true
          control.hide
          control.visible?.should be_false
          control.show
          control.visible?.should be_true
          control.toplevel?.should be_false
          control.enabled_to_user?
          control.handle
        end
      ensure
        window.try { |control| control.destroy unless control.released? }
      end

      it "exposes control handles as pointers through the uintptr_t FFI" do
        button = UIng::Button.new("Native handle")

        handle = button.handle
        handle.should be_a(Pointer(Void))
        handle.null?.should be_false
      ensure
        button.try &.destroy
      end

      it "sets and resets control minimum sizes" do
        window = UIng::Window.new("Minimum size spec", 320, 200)
        box = UIng::Box.new(:vertical)
        button = UIng::Button.new("Button")
        box.append(button)
        window.child = box

        button.set_minimum_size(160, -1)
        button.set_minimum_size(-1, 48)
        button.set_minimum_size(0, 0)
        button.set_minimum_size(-1, -1)

        expect_raises(ArgumentError, /at least -1/) do
          button.set_minimum_size(-2, 10)
        end
        expect_raises(ArgumentError, /top-level/) do
          window.set_minimum_size(320, 200)
        end
      ensure
        window.try { |control| control.destroy unless control.released? }
      end

      it "sets and removes descriptive control tooltips" do
        window = UIng::Window.new("Tooltip spec", 320, 200)
        box = UIng::Box.new(:vertical)
        button = UIng::Button.new("Button")
        slider = UIng::Slider.new(0, 100)
        box.append(button)
        box.append(slider)
        window.child = box

        window.tooltip = "Window tooltip"
        button.tooltip = "日本語 tooltip\nsecond line"
        button.tooltip = ""
        button.tooltip = nil

        slider.has_tool_tip = false
        slider.tooltip = "Descriptive slider tooltip"
        slider.has_tool_tip?.should be_false
        slider.tooltip = nil
        slider.has_tool_tip?.should be_false

        slider.has_tool_tip = true
        slider.tooltip = "Replacement tooltip"
        slider.tooltip = nil
        slider.has_tool_tip?.should be_true

        slider.range = 10..90
        slider.set_range(0, 100)
      ensure
        window.try { |control| control.destroy unless control.released? }
      end

      it "requests control focus and queries the result" do
        window = UIng::Window.new("Control focus", 300, 200)
        entry = UIng::Entry.new
        window.child = entry
        begin
          window.show
          entry.focus
          entry.focused?.should be_a(Bool)
        ensure
          window.destroy
        end
      end
    end

    describe "native destruction" do
      it "destroys top-level controls through a Control array" do
        first = UIng::Window.new("First polymorphic destroy", 320, 200)
        second = NativeLifecycleWindow.new("Second polymorphic destroy", 320, 200)
        controls = [first, second] of UIng::Control

        controls.each(&.destroy)
        controls.all?(&.released?).should be_true

        deadline = Time.instant + 5.seconds
        until second.native_destroyed?
          UIng.main_step(false)
          raise "timed out waiting for polymorphic destruction" if Time.instant >= deadline
          sleep 1.millisecond
        end

        controls.each(&.destroy)
      ensure
        first.try { |control| control.destroy unless control.released? }
        second.try { |control| control.destroy unless control.released? }
      end

      it "flushes deferred parent and child destruction after an event callback" do
        controls = [] of UIng::Control
        callback_errors = [] of Exception
        destroy_was_requested = false

        UIng.on_error { |error, _context| callback_errors << error }
        begin
          # Exercise several complete native ownership trees. Keeping every
          # control attached to a Window also mirrors real application usage and
          # avoids testing GTK's unrelated floating-widget behavior.
          windows = Array(UIng::Window).new(8) do |index|
            window = UIng::Window.new("UIng lifecycle spec #{index}", 320, 200)
            box = UIng::Box.new(:horizontal)
            button = UIng::Button.new("child #{index}")
            box.append(button)
            window.child = box
            window.show if index == 0
            controls << window << box << button
            window
          end

          # queue_main is a genuine libui user callback, so these destroys are
          # deferred until the callback has returned.
          UIng.main_steps
          UIng.queue_main do
            windows.each(&.destroy)
            destroy_was_requested = true
          end

          deadline = Time.instant + 5.seconds
          until destroy_was_requested && controls.all?(&.released?)
            UIng.main_step(false)
            raise "timed out waiting for native destruction callbacks" if Time.instant >= deadline
            sleep 1.millisecond
          end
        ensure
          UIng.on_error(nil)
        end

        callback_errors.should be_empty
        controls.each do |control|
          control.parent.should be_nil
          pointer_is_unavailable?(control).should be_true
        end
      end

      it "destroys a native Control tree when block construction raises" do
        window : NativeLifecycleWindow? = nil
        child : UIng::Button? = nil

        expect_raises(Exception, "construction failed") do
          NativeLifecycleWindow.new("Construction failure", 320, 200) do |candidate|
            window = candidate
            child = UIng::Button.new("Child")
            candidate.child = child
            raise "construction failed"
          end
        end

        deadline = Time.instant + 5.seconds
        until window.try(&.native_destroyed?)
          UIng.main_step(false)
          raise "timed out waiting for failed construction cleanup" if Time.instant >= deadline
          sleep 1.millisecond
        end

        window.try(&.released?).should be_true
        child.try(&.released?).should be_true
      end

      it "contains after_destroy exceptions at the native destruction boundary" do
        button = NativeFailingAfterDestroyButton.new
        callback_errors = [] of {Exception, String}
        UIng.on_error { |error, context| callback_errors << {error, context} }

        button.destroy

        deadline = Time.instant + 5.seconds
        until button.state_name == "Destroyed"
          UIng.main_step(false)
          raise "timed out waiting for native destruction" if Time.instant >= deadline
        end

        button.after_destroy_called?.should be_true
        button.parent.should be_nil
        callback_errors.size.should eq(1)
        callback_errors[0][0].message.should eq("native after_destroy failed")
        callback_errors[0][1].should contain("after_destroy")
      ensure
        UIng.on_error(nil)
      end
    end
  end
{% end %}
