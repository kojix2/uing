require "../spec_helper"

private class BlockToolbarForSpec < UIng::Toolbar
  block_constructor
  getter native_free_calls = 0

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Toolbar).null
  end

  protected def free_native : Nil
    @native_free_calls += 1
  end
end

private class ToolbarDslWindow < UIng::Window
  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Window).null
  end

  protected def set_native_toolbar(toolbar : Pointer(UIng::LibUI::Toolbar)) : Nil
  end

  def release_for_spec : Nil
    mark_destroyed_from_native
  end
end

describe UIng::Toolbar do
  it "attaches the block result and leaves a successful constructor alive" do
    window = ToolbarDslWindow.new
    constructed = nil
    result = window.toolbar do
      BlockToolbarForSpec.new do |bar|
        constructed = bar
        to_unsafe.should eq(bar.to_unsafe)
        :ignored
      end
    end

    result.should be_nil
    toolbar = constructed.should_not be_nil
    window.toolbar.should be(toolbar)
    toolbar.attached?.should be_true
    toolbar.native_free_calls.should eq(0)
    window.release_for_spec
    toolbar.native_free_calls.should eq(1)
  end

  it "detaches and frees a Toolbar if construction raises after attachment" do
    window = ToolbarDslWindow.new
    constructed = nil
    original = Exception.new("toolbar construction failed")
    error = expect_raises(Exception, original.message) do
      BlockToolbarForSpec.new do |bar|
        constructed = bar
        window.toolbar = bar
        raise original
      end
    end

    error.should be(original)
    toolbar = constructed.should_not be_nil
    window.toolbar.should be_nil
    toolbar.released?.should be_true
    toolbar.native_free_calls.should eq(1)
    toolbar.free
    window.release_for_spec
    toolbar.native_free_calls.should eq(1)
  end

  it "preserves ownership when attachment to a second Window fails" do
    first = ToolbarDslWindow.new
    second = ToolbarDslWindow.new
    toolbar = BlockToolbarForSpec.new
    first.toolbar { toolbar }

    expect_raises(Exception, /already attached to another Window/) do
      second.toolbar { toolbar }
    end
    first.toolbar.should be(toolbar)
    second.toolbar.should be_nil
    toolbar.released?.should be_false
    first.release_for_spec
    second.release_for_spec
    toolbar.native_free_calls.should eq(1)
  end

  it "rejects a destroyed Window before constructing a Toolbar" do
    window = ToolbarDslWindow.new
    window.release_for_spec
    called = false
    expect_raises(Exception, /already been destroyed/) do
      window.toolbar do
        called = true
        BlockToolbarForSpec.new
      end
    end
    called.should be_false
  end

  it "keeps the current Toolbar when construction of a replacement fails" do
    window = ToolbarDslWindow.new
    current = BlockToolbarForSpec.new
    window.toolbar = current
    replacement = nil

    expect_raises(Exception, "replacement failed") do
      window.toolbar do
        BlockToolbarForSpec.new do |bar|
          replacement = bar
          raise "replacement failed"
        end
      end
    end

    window.toolbar.should be(current)
    current.released?.should be_false
    replacement.should_not(be_nil).native_free_calls.should eq(1)
    window.release_for_spec
    current.native_free_calls.should eq(1)
  end
end
