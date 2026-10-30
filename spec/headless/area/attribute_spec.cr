require "../../spec_helper"
require "../../support/attributes"

private class BorrowedLifetimeSafetyAttribute < UIng::Area::Attribute
  def initialize
    super(Pointer(UIng::LibUI::Attribute).null, borrowed: true)
  end

  def invalidate_after_callback : Nil
    invalidate_borrow
  end
end

describe UIng::Area::Attribute do
  it "rejects every Attribute operation after free" do
    attribute = SpecSupport::ReleasedLifetimeSafetyAttribute.new

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
  end

  it "rejects a borrowed Attribute after its callback ends" do
    attribute = BorrowedLifetimeSafetyAttribute.new
    attribute.invalidate_after_callback

    expect_raises(Exception, /already been released/) { attribute.to_unsafe }
  end
end
