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

  it "rejects invalid timer intervals before retaining or calling the callback" do
    callback_called = false

    [0_i64, -1_i64, Int32::MAX.to_i64 + 1].each do |interval|
      expect_raises(ArgumentError, /between 1 and Int32::MAX/) do
        UIng.timer(interval) do
          callback_called = true
          0
        end
      end
    end

    callback_called.should be_false
  end
end
