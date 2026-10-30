require "../spec_helper"

describe "UIng::LibUI" do
  it "uses pointer-sized and unsigned enum FFI types" do
    sizeof(UIng::LibUI::UIntPtr).should eq(sizeof(Pointer(Void)))
    sizeof(UIng::LibUI::ForEach).should eq(sizeof(UInt32))
    sizeof(UIng::LibUI::DropFormat).should eq(sizeof(LibC::UInt))
    sizeof(UIng::LibUI::DropAction).should eq(sizeof(LibC::UInt))
    sizeof(UIng::LibUI::DropResult).should eq(sizeof(LibC::UInt))
    sizeof(UIng::LibUI::DropStatus).should eq(sizeof(LibC::UInt))
  end
end
