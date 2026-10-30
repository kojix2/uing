require "../spec_helper"
require "../support/callback_errors"
require "../support/controls"

private class BlockConstructedLifetimeControl < SpecSupport::LifetimeControl
  block_constructor
end

private class PendingPointerControl < SpecSupport::LifetimeControl
  getter destroyed_address : UInt64?

  protected def destroy_native : Nil
    @destroyed_address = raw_control_ptr.address
  end
end

private class KeywordBlockConstructedLifetimeControl < SpecSupport::LifetimeControl
  block_constructor

  def initialize(*, address : UInt64 = 0_u64)
    super(address)
  end
end

private class FailingCleanupBlockControl < SpecSupport::LifetimeControl
  block_constructor

  protected def __block_constructor_failed__ : Nil
    raise "cleanup failed"
  end
end

describe UIng::Control do
  it "detaches and destroys a Control when block construction raises" do
    parent = SpecSupport::LifetimeContainer.new
    constructed : BlockConstructedLifetimeControl? = nil
    original_error = Exception.new("construction failed")

    error = expect_raises(Exception, "construction failed") do
      BlockConstructedLifetimeControl.new do |control|
        constructed = control
        parent.adopt_child(control)
        raise original_error
      end
    end

    error.same?(original_error).should be_true
    control = constructed || raise "block did not yield its Control"
    control.released?.should be_true
    control.parent.should be_nil
    parent.contains?(control).should be_false
  end

  it "cleans up a Control created with keyword arguments" do
    constructed : KeywordBlockConstructedLifetimeControl? = nil

    expect_raises(Exception, "construction failed") do
      KeywordBlockConstructedLifetimeControl.new(address: 0x110_u64) do |control|
        constructed = control
        raise "construction failed"
      end
    end

    constructed.try(&.released?).should be_true
  end

  it "preserves the construction error when cleanup also raises" do
    callback_errors = [] of {Exception, String}
    UIng.on_error { |error, context| callback_errors << {error, context} }

    error = UIng.expect_callback_error_log("cleanup failed", "FailingCleanupBlockControl block construction cleanup") do
      expect_raises(Exception, "construction failed") do
        FailingCleanupBlockControl.new do
          raise "construction failed"
        end
      end
    end

    error.message.should eq("construction failed")
    callback_errors.size.should eq(1)
    callback_errors[0][0].message.should eq("cleanup failed")
    callback_errors[0][1].should contain("block construction cleanup")
  ensure
    UIng.on_error(nil)
  end

  it "moves through Alive, DestroyPending, and Destroyed" do
    address = 0x104_u64
    control = SpecSupport::LifetimeControl.new(address, register: true)
    ptr = Pointer(UIng::LibUI::Button).new(address)

    control.state_name.should eq("Alive")
    control.destroy
    control.state_name.should eq("DestroyPending")
    control.cleaned_up?.should be_false

    UIng.native_control_destroyed_for_spec(ptr)
    control.state_name.should eq("Destroyed")
    control.cleaned_up?.should be_true
  end

  it "keeps the native pointer available to destruction after marking a Control pending" do
    address = 0x10B_u64
    control = PendingPointerControl.new(address)
    controls = [control] of UIng::Control

    controls.each(&.destroy)

    control.released?.should be_true
    control.destroyed_address.should eq(address)
    expect_raises(Exception, /already been destroyed/) { control.to_unsafe }
  end

  it "rejects direct destroy while the control is owned by a parent" do
    parent = SpecSupport::LifetimeContainer.new
    child = SpecSupport::LifetimeControl.new
    parent.adopt_child(child)

    expect_raises(Exception, /destroy a child control directly/) do
      child.destroy
    end

    child.released?.should be_false
    child.parent.should eq(parent)
  end

  it "detaches through the owning container and can then be destroyed" do
    parent = SpecSupport::LifetimeContainer.new
    child = SpecSupport::LifetimeControl.new
    parent.adopt_child(child)

    child.detach.should be(child)
    child.parent.should be_nil
    child.destroy
    child.state_name.should eq("DestroyPending")
  end

  it "rejects checked pointer access after a native destroy notification" do
    address = 0x107_u64
    child = SpecSupport::LifetimeControl.new(address, register: true)
    UIng.native_control_destroyed_for_spec(Pointer(UIng::LibUI::Button).new(address))

    expect_raises(Exception, /already been destroyed/) do
      child.to_unsafe
    end
  end

  it "rejects common operations on destroyed controls in a mixed Control array" do
    button_address = 0x109_u64
    area_address = 0x10A_u64
    button = SpecSupport::LifetimeControl.new(button_address, register: true)
    area = SpecSupport::RegistryArea.new(area_address)
    controls : Array(UIng::Control) = [button, area]

    UIng.native_control_destroyed_for_spec(Pointer(UIng::LibUI::Button).new(button_address))
    UIng.native_control_destroyed_for_spec(Pointer(UIng::LibUI::Area).new(area_address))

    controls.each do |control|
      expect_raises(Exception, /already been destroyed/) { control.disable }
      expect_raises(Exception, /already been destroyed/) { control.enable }
      expect_raises(Exception, /already been destroyed/) { control.enabled? }
      expect_raises(Exception, /already been destroyed/) { control.hide }
      expect_raises(Exception, /already been destroyed/) { control.show }
      expect_raises(Exception, /already been destroyed/) { control.visible? }
      expect_raises(Exception, /already been destroyed/) { control.toplevel? }
      expect_raises(Exception, /already been destroyed/) { control.handle }
      expect_raises(Exception, /already been destroyed/) { control.enabled_to_user? }
    end
  end
end
