require "../../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Area::AttributedString do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "validates AttributedString boundaries without transferring invalid attributes" do
      string = UIng::Area::AttributedString.new("Aé🙂B")
      empty_string = UIng::Area::AttributedString.new("")
      attribute = UIng::Area::Attribute.new_color(1.0, 0.0, 0.0, 1.0)

      {0 => 0, 1 => 1, 3 => 2, 7 => 3, 8 => 4}.each do |byte_index, grapheme_index|
        string.byte_index_to_grapheme(LibC::SizeT.new(byte_index)).should eq(LibC::SizeT.new(grapheme_index))
      end
      {0 => 0, 1 => 1, 2 => 3, 3 => 7, 4 => 8}.each do |grapheme_index, byte_index|
        string.grapheme_to_byte_index(LibC::SizeT.new(grapheme_index)).should eq(LibC::SizeT.new(byte_index))
      end
      [2, 4, 5, 6].each do |position|
        expect_raises(ArgumentError, /insertion position is not on a UTF-8/) do
          string.insert_at_unattributed("x", LibC::SizeT.new(position))
        end
      end
      expect_raises(ArgumentError, /deletion range is out of bounds/) { string.delete(0, 9) }
      expect_raises(ArgumentError, /attribute range start is not on a UTF-8/) do
        string.set_attribute(attribute, 2, 3)
      end
      attribute.released?.should be_false

      expect_raises(ArgumentError, /grapheme index is out of bounds/) do
        string.grapheme_to_byte_index(5)
      end

      empty_string.byte_index_to_grapheme(0).should eq(0)
      empty_string.grapheme_to_byte_index(0).should eq(0)

      string.insert_at_unattributed("-", 3)
      string.string.should eq("Aé-🙂B")
      string.delete(4, 8)
      string.string.should eq("Aé-B")
      string.set_attribute(attribute, 1, 3)
      attribute.released?.should be_true
    ensure
      attribute.try &.free
      empty_string.try &.free
      string.try &.free
    end

    it "rejects AttributedString mutation during enumeration and preserves its owner" do
      string = UIng::Area::AttributedString.new("abcd")
      string.set_attribute(UIng::Area::Attribute.new_size(12.0), 0, 2)
      string.set_attribute(UIng::Area::Attribute.new_weight(UIng::TextWeight::Bold), 2, 4)
      errors = [] of Exception
      UIng.on_error { |error, _context| errors << error }

      visits = 0
      string.each_attribute do |_attribute, _start, _end|
        visits += 1
        string.append_unattributed("x")
      end

      visits.should eq(1)
      errors.size.should eq(1)
      errors.first.message.to_s.should contain("being enumerated")
      string.string.should eq("abcd")

      nested_visits = 0
      string.each_attribute do |_outer_attribute, _outer_start, _outer_end|
        string.each_attribute do |_inner_attribute, _inner_start, _inner_end|
          nested_visits += 1
        end
      end
      nested_visits.should eq(4)

      limited_visits = 0
      string.each_attribute_while do |_attribute, _start, _end|
        limited_visits += 1
        false
      end
      limited_visits.should eq(1)
    ensure
      UIng.on_error(nil)
      string.try &.free
    end

    it "rejects every AttributedString operation after free" do
      string = UIng::Area::AttributedString.new("abc")
      attribute = UIng::Area::Attribute.new_size(12)
      string.free
      attribute.free

      expect_raises(Exception, /already been released/) { string.string }
      expect_raises(Exception, /already been released/) { string.len }
      expect_raises(Exception, /already been released/) { string.append_unattributed("x") }
      expect_raises(Exception, /already been released/) { string.insert_at_unattributed("x", 0) }
      expect_raises(Exception, /already been released/) { string.delete(0, 0) }
      expect_raises(Exception, /already been released/) { string.set_attribute(attribute, 0, 0) }
      expect_raises(Exception, /already been released/) do
        string.each_attribute { |_attribute, _start, _end| }
      end
      expect_raises(Exception, /already been released/) { string.num_graphemes }
      expect_raises(Exception, /already been released/) { string.byte_index_to_grapheme(0) }
      expect_raises(Exception, /already been released/) { string.grapheme_to_byte_index(0) }
      expect_raises(Exception, /already been released/) { string.to_unsafe }
    ensure
      attribute.try &.free
      string.try &.free
    end
  end
{% end %}
