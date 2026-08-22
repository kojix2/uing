require "./spec_helper"

module UIng
  def self.registered_control_for_spec(ptr : Pointer(T)) : Control? forall T
    ControlRegistry.lookup(ptr)
  end

  def self.native_control_destroyed_for_spec(ptr : Pointer(T)) : Nil forall T
    ControlRegistry.native_destroyed(ptr)
  end
end

private class LifetimeControl < UIng::Control
  @ref_ptr : Pointer(UIng::LibUI::Button)

  getter? cleaned_up = false

  def initialize(address : UInt64 = 0_u64, register : Bool = false)
    @ref_ptr = Pointer(UIng::LibUI::Button).new(address)
    register_control(install_destroy_callback: false) if register
  end

  def adopt(parent : UIng::Control) : Nil
    take_ownership(parent)
  end

  def state_name : String
    lifecycle_state.to_s
  end

  protected def destroy_native : Nil
  end

  protected def after_destroy : Nil
    @cleaned_up = true
  end

  def to_unsafe
    ref_ptr
  end
end

private class LifetimeContainer < LifetimeControl
  @child : UIng::Control?

  def initialize(@child : UIng::Control? = nil, address : UInt64 = 0_u64, register : Bool = false)
    super(address, register)
  end

  def adopt_child(child : LifetimeControl) : Nil
    @child = child
    child.adopt(self)
  end

  def delete(child : UIng::Control)
    unless @child.same?(child)
      raise "LifetimeContainer does not contain child"
    end
    @child = nil
    child.release_ownership
  end

  protected def after_destroy : Nil
    super
    @child = nil
  end
end

private class RegistryWindow < UIng::Window
  def initialize(address : UInt64)
    @ref_ptr = Pointer(UIng::LibUI::Window).new(address)
    register_control(install_destroy_callback: false)
  end

  def close_result(&block : -> Bool) : Bool
    handle_closing(block)
  end

  def state_name : String
    lifecycle_state.to_s
  end

  protected def destroy_native : Nil
  end
end

private class RegistryArea < UIng::Area
  def initialize(address : UInt64)
    @ref_ptr = Pointer(UIng::LibUI::Area).new(address)
    register_control(install_destroy_callback: false)
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

describe UIng::Control do
  it "keeps the same wrapper identity for repeated native pointer lookups" do
    address = 0x101_u64
    control = LifetimeControl.new(address, register: true)
    ptr = Pointer(UIng::LibUI::Button).new(address)

    UIng.registered_control_for_spec(ptr).should be(control)
    UIng.registered_control_for_spec(ptr).should be(control)

    UIng.native_control_destroyed_for_spec(ptr)
    UIng.registered_control_for_spec(ptr).should be_nil
  end

  it "rejects a second wrapper for the same native pointer" do
    address = 0x108_u64
    control = LifetimeControl.new(address, register: true)
    ptr = Pointer(UIng::LibUI::Button).new(address)

    expect_raises(Exception, /already has a registered wrapper/) do
      LifetimeControl.new(address, register: true)
    end

    UIng.registered_control_for_spec(ptr).should be(control)
    UIng.native_control_destroyed_for_spec(ptr)
  end

  it "unregisters a child when native parent destruction destroys it" do
    parent_address = 0x102_u64
    child_address = 0x103_u64
    parent = LifetimeContainer.new(address: parent_address, register: true)
    child = LifetimeControl.new(child_address, register: true)
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
    parent = LifetimeContainer.new(address: parent_address, register: true)
    child = LifetimeContainer.new(address: child_address, register: true)
    grandchild = LifetimeControl.new(grandchild_address, register: true)
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

  it "moves through Alive, DestroyPending, and Destroyed" do
    address = 0x104_u64
    control = LifetimeControl.new(address, register: true)
    ptr = Pointer(UIng::LibUI::Button).new(address)

    control.state_name.should eq("Alive")
    control.destroy
    control.state_name.should eq("DestroyPending")
    control.cleaned_up?.should be_false

    UIng.native_control_destroyed_for_spec(ptr)
    control.state_name.should eq("Destroyed")
    control.cleaned_up?.should be_true
  end

  it "marks a closing Window pending before native destruction is flushed" do
    address = 0x10C_u64
    window = RegistryWindow.new(address)
    ptr = Pointer(UIng::LibUI::Window).new(address)

    window.close_result { true }.should be_true
    window.state_name.should eq("DestroyPending")
    UIng.registered_control_for_spec(ptr).should be(window)

    UIng.native_control_destroyed_for_spec(ptr)
    window.state_name.should eq("Destroyed")
  end

  it "does not request a second native close after user code starts destruction" do
    address = 0x10D_u64
    window = RegistryWindow.new(address)
    ptr = Pointer(UIng::LibUI::Window).new(address)

    window.close_result do
      window.destroy
      true
    end.should be_false
    window.state_name.should eq("DestroyPending")

    UIng.native_control_destroyed_for_spec(ptr)
  end

  it "reuses registered Window wrappers in menu callbacks and preserves NULL" do
    address = 0x105_u64
    window = RegistryWindow.new(address)
    item = RegistryMenuItem.new
    ptr = Pointer(UIng::LibUI::Window).new(address)

    item.resolve_window(ptr).should be(window)
    item.resolve_window(Pointer(UIng::LibUI::Window).null).should be_nil

    UIng.native_control_destroyed_for_spec(ptr)
  end

  it "reuses a registered Area wrapper in draw callbacks" do
    address = 0x106_u64
    area = RegistryArea.new(address)
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

  it "rejects direct destroy while the control is owned by a parent" do
    parent = LifetimeContainer.new
    child = LifetimeControl.new
    parent.adopt_child(child)

    expect_raises(Exception, /destroy a child control directly/) do
      child.destroy
    end

    child.released?.should be_false
    child.parent.should eq(parent)
  end

  it "detaches through the owning container and can then be destroyed" do
    parent = LifetimeContainer.new
    child = LifetimeControl.new
    parent.adopt_child(child)

    child.detach.should be(child)
    child.parent.should be_nil
    child.destroy
    child.state_name.should eq("DestroyPending")
  end

  it "rejects checked pointer access after a native destroy notification" do
    address = 0x107_u64
    child = LifetimeControl.new(address, register: true)
    UIng.native_control_destroyed_for_spec(Pointer(UIng::LibUI::Button).new(address))

    expect_raises(Exception, /already been destroyed/) do
      child.to_unsafe
    end
  end
end
