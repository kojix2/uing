require "../spec_helper"

if ENV["UING_NATIVE_GUI_TESTS"]? == "1"
  describe "native image size" do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "reads logical dimensions from libui-ng and preserves them in a copy" do
      image = UIng::Image.new(12.5, 7.5)
      begin
        image.size.should eq({12.5, 7.5})
        image.width.should eq(12.5)
        image.height.should eq(7.5)

        image.append(Bytes.new(25 * 15 * 4), 25, 15, 25 * 4)
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
  end
end
