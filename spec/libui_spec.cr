require "./spec_helper"

describe UIng do
  it "reports the linked libui-ng version" do
    UIng.libui_version.should match(/\A(?:(?:commit-[0-9a-f]+(?:-experimental)?|[0-9a-f]+)(?:-dirty)?|unknown)\z/)
  end

  it "uses pointer-sized and unsigned enum FFI types" do
    sizeof(UIng::LibUI::UIntPtr).should eq(sizeof(Pointer(Void)))
    sizeof(UIng::LibUI::ForEach).should eq(sizeof(UInt32))
  end

  it "has a version number" do
    UIng::VERSION.should be_a(String)
  end

  it "does not invoke native shutdown when the runtime is already inactive" do
    UIng.uninit
    UIng.uninit
  end
end
