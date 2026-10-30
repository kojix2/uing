require "../../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Area::Attribute do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "rejects every Attribute operation after free" do
      attribute = UIng::Area::Attribute.new_size(12)
      attribute.free

      expect_raises(Exception, /already been released/) { attribute.type }
      expect_raises(Exception, /already been released/) { attribute.family }
      expect_raises(Exception, /already been released/) { attribute.size }
      expect_raises(Exception, /already been released/) { attribute.weight }
      expect_raises(Exception, /already been released/) { attribute.italic }
      expect_raises(Exception, /already been released/) { attribute.stretch }
      expect_raises(Exception, /already been released/) { attribute.color }
      expect_raises(Exception, /already been released/) { attribute.underline }
      expect_raises(Exception, /already been released/) { attribute.underline_color }
      expect_raises(Exception, /already been released/) { attribute.features }
      expect_raises(Exception, /already been released/) { attribute.to_unsafe }
    ensure
      attribute.try &.free
    end

    it "rejects a borrowed Attribute after its callback ends" do
      UIng::Area::AttributedString.open("abc") do |string|
        string.set_attribute(UIng::Area::Attribute.new_size(12), 0, 3)
        borrowed : UIng::Area::Attribute? = nil
        string.each_attribute do |attribute, _start, _end|
          attribute.released?.should be_false
          attribute.size.should eq(12.0)
          borrowed = attribute
        end

        attribute = borrowed.should_not be_nil
        attribute.released?.should be_true
        expect_raises(Exception, /already been released/) { attribute.to_unsafe }
        string.string.should eq("abc")
      end
    end
  end
{% end %}
