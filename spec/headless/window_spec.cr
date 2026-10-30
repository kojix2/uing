require "../spec_helper"
require "../support/containers"
require "../support/controls"

describe UIng::Window do
  describe "child ownership" do
    it "supports the Window child block DSL" do
      window = SpecSupport::DetachableWindow.new
      child = SpecSupport::DetachableControl.new

      window.child { child }

      window.child.should be(child)
      child.parent.should be(window)
    end

    it "clears and detaches a Window child" do
      window = SpecSupport::DetachableWindow.new
      child = SpecSupport::DetachableControl.new
      window.child = child

      window.child.should be(child)
      child.detach

      window.child.should be_nil
      child.parent.should be_nil
      window.native_child_cleared?.should be_true
    end

    it "preserves Window ownership when child replacement is attempted while destruction is pending" do
      window = SpecSupport::DetachableWindow.new
      old_child = SpecSupport::DetachableControl.new
      new_child = SpecSupport::DetachableControl.new
      window.child = old_child
      window.destroy

      expect_raises(Exception, /already been destroyed/) do
        window.child = new_child
      end

      window.child.should be(old_child)
      old_child.parent.should be(window)
      new_child.parent.should be_nil
    end
  end

  describe "closing" do
    it "marks a closing Window pending before native destruction is flushed" do
      address = 0x10C_u64
      window = SpecSupport::RegistryWindow.new(address)
      ptr = Pointer(UIng::LibUI::Window).new(address)

      window.close_result { true }.should be_true
      window.state_name.should eq("DestroyPending")
      UIng.registered_control_for_spec(ptr).should be(window)

      UIng.native_control_destroyed_for_spec(ptr)
      window.state_name.should eq("Destroyed")
    end

    it "does not request a second native close after user code starts destruction" do
      address = 0x10D_u64
      window = SpecSupport::RegistryWindow.new(address)
      ptr = Pointer(UIng::LibUI::Window).new(address)

      window.close_result do
        window.destroy
        true
      end.should be_false
      window.state_name.should eq("DestroyPending")

      UIng.native_control_destroyed_for_spec(ptr)
    end
  end
end
