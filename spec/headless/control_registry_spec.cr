require "../spec_helper"
require "../support/callback_errors"
require "../support/controls"

private class RaisingAfterDestroyControl < SpecSupport::LifetimeControl
  protected def after_destroy : Nil
    super
    raise "after_destroy failed"
  end
end

private class RegistryMenuItem < UIng::MenuItem
  def initialize
    super(Pointer(UIng::LibUI::MenuItem).null)
  end

  def resolve_window(window : Pointer(UIng::LibUI::Window)) : UIng::Window?
    window_from_native(window)
  end
end

describe "control registry" do
  describe "wrapper identity" do
    it "keeps the same wrapper identity for repeated native pointer lookups" do
      address = 0x101_u64
      control = SpecSupport::LifetimeControl.new(address, register: true)
      ptr = Pointer(UIng::LibUI::Button).new(address)

      UIng.registered_control_for_spec(ptr).should be(control)
      UIng.registered_control_for_spec(ptr).should be(control)

      UIng.native_control_destroyed_for_spec(ptr)
      UIng.registered_control_for_spec(ptr).should be_nil
    end

    it "rejects a second wrapper for the same native pointer" do
      address = 0x108_u64
      control = SpecSupport::LifetimeControl.new(address, register: true)
      ptr = Pointer(UIng::LibUI::Button).new(address)

      expect_raises(Exception, /already has a registered wrapper/) do
        SpecSupport::LifetimeControl.new(address, register: true)
      end

      UIng.registered_control_for_spec(ptr).should be(control)
      UIng.native_control_destroyed_for_spec(ptr)
    end

    it "reuses registered Window wrappers in menu callbacks and preserves NULL" do
      address = 0x105_u64
      window = SpecSupport::RegistryWindow.new(address)
      item = RegistryMenuItem.new
      ptr = Pointer(UIng::LibUI::Window).new(address)

      item.resolve_window(ptr).should be(window)
      item.resolve_window(Pointer(UIng::LibUI::Window).null).should be_nil

      UIng.native_control_destroyed_for_spec(ptr)
    end

    it "reuses a registered Area wrapper in draw callbacks" do
      address = 0x106_u64
      area = SpecSupport::RegistryArea.new(address)
      handler = UIng::Area::Handler.new
      received : UIng::Area? = nil
      handler.draw { |callback_area, _params| received = callback_area }
      handler_ptr = handler.to_unsafe
      draw_params = UIng::LibUI::AreaDrawParams.new

      handler_ptr.value.draw.call(
        handler_ptr,
        Pointer(UIng::LibUI::Area).new(address),
        pointerof(draw_params)
      )

      received.should be(area)
      UIng.native_control_destroyed_for_spec(Pointer(UIng::LibUI::Area).new(address))
    end
  end

  describe "native destruction" do
    it "unregisters a child when native parent destruction destroys it" do
      parent_address = 0x102_u64
      child_address = 0x103_u64
      parent = SpecSupport::LifetimeContainer.new(address: parent_address, register: true)
      child = SpecSupport::LifetimeControl.new(child_address, register: true)
      parent.adopt_child(child)

      UIng.native_control_destroyed_for_spec(Pointer(UIng::LibUI::Button).new(child_address))
      UIng.native_control_destroyed_for_spec(Pointer(UIng::LibUI::Button).new(parent_address))

      child.state_name.should eq("Destroyed")
      child.parent.should be_nil
      UIng.registered_control_for_spec(Pointer(UIng::LibUI::Button).new(child_address)).should be_nil
    end

    it "unregisters every wrapper in a three-level native destruction cascade" do
      parent_address = 0x109_u64
      child_address = 0x10A_u64
      grandchild_address = 0x10B_u64
      parent = SpecSupport::LifetimeContainer.new(address: parent_address, register: true)
      child = SpecSupport::LifetimeContainer.new(address: child_address, register: true)
      grandchild = SpecSupport::LifetimeControl.new(grandchild_address, register: true)
      parent.adopt_child(child)
      child.adopt_child(grandchild)

      pointers = {
        Pointer(UIng::LibUI::Button).new(grandchild_address),
        Pointer(UIng::LibUI::Button).new(child_address),
        Pointer(UIng::LibUI::Button).new(parent_address),
      }
      pointers.each { |ptr| UIng.native_control_destroyed_for_spec(ptr) }

      {parent, child, grandchild}.each do |control|
        control.state_name.should eq("Destroyed")
        control.parent.should be_nil
      end
      pointers.each do |ptr|
        UIng.registered_control_for_spec(ptr).should be_nil
      end
    end

    it "contains after_destroy errors after completing lifecycle cleanup" do
      address = 0x10C_u64
      parent = SpecSupport::LifetimeContainer.new
      control = RaisingAfterDestroyControl.new(address, register: true)
      parent.adopt_child(control)
      ptr = Pointer(UIng::LibUI::Button).new(address)
      callback_errors = [] of {Exception, String}
      UIng.on_error { |error, context| callback_errors << {error, context} }

      UIng.expect_callback_error_log("after_destroy failed", "Control after_destroy") do
        UIng.native_control_destroyed_for_spec(ptr)
      end

      control.cleaned_up?.should be_true
      control.state_name.should eq("Destroyed")
      control.parent.should be_nil
      UIng.registered_control_for_spec(ptr).should be_nil
      callback_errors.size.should eq(1)
      callback_errors[0][0].message.should eq("after_destroy failed")
      callback_errors[0][1].should contain("after_destroy")
    ensure
      UIng.on_error(nil)
    end
  end
end
