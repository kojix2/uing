require "../spec_helper"

describe "UIng::LibUI" do
  it "reports the linked libui-ng version" do
    UIng.libui_version.should match(/\A(?:(?:commit-[0-9a-f]+(?:-experimental)?|[0-9a-f]+)(?:-dirty)?|unknown)\z/)
  end

  it "uses pointer-sized and unsigned enum FFI types" do
    sizeof(UIng::LibUI::UIntPtr).should eq(sizeof(Pointer(Void)))
    sizeof(UIng::LibUI::ForEach).should eq(sizeof(UInt32))
    sizeof(UIng::LibUI::DropFormat).should eq(sizeof(LibC::UInt))
    sizeof(UIng::LibUI::DropAction).should eq(sizeof(LibC::UInt))
    sizeof(UIng::LibUI::DropResult).should eq(sizeof(LibC::UInt))
    sizeof(UIng::LibUI::DropStatus).should eq(sizeof(LibC::UInt))
  end

  it "has a version number" do
    UIng::VERSION.should be_a(String)
  end
end
