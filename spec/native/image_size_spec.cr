require "../spec_helper"

if ENV["UING_NATIVE_GUI_TESTS"]? == "1"
  describe "native image size" do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "reads logical dimensions from libui-ng and preserves them in a copy" do
      image = UIng::Image.new(12.5, 7.5) do
        append(Bytes.new(25 * 15 * 4), 25, 15, 25 * 4)
      end
      begin
        image.size.should eq({12.5, 7.5})
        image.width.should eq(12.5)
        image.height.should eq(7.5)

        image.append(Bytes.new(50 * 30 * 4), 50, 30, 50 * 4)
        image.size.should eq({12.5, 7.5})

        copy = image.copy
        begin
          copy.size.should eq({12.5, 7.5})
        ensure
          copy.free
        end
      ensure
        image.free
      end

      expect_raises(Exception, /already been released/) { image.size }
    end

    it "frees an Image when its configuration block raises" do
      escaped = nil
      expect_raises(Exception, "image configuration failed") do
        UIng::Image.new(width: 1, height: 1) do |image|
          escaped = image
          append(Bytes[255, 0, 0, 255], 1, 1, 4)
          raise "image configuration failed"
        end
      end

      image = escaped.should_not be_nil
      expect_raises(Exception, /already been released/) { image.to_unsafe }
      image.free
    end
  end
end
