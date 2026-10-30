require "./spec_helper"

private class SavedDrawingContext < UIng::Area::Draw::Context
  getter calls = [] of Symbol
  property? fail_save = false

  def initialize
    super(Pointer(UIng::LibUI::DrawContext).null)
  end

  def save : Nil
    @calls << :save
    raise "save failed" if @fail_save
  end

  def restore : Nil
    @calls << :restore
  end

  def transform(matrix : UIng::Area::Draw::Matrix) : Nil
    @calls << :transform
  end
end

describe UIng::Area::Draw::Context do
  it "runs saved blocks with the Context as receiver and argument and returns their result" do
    context = SavedDrawingContext.new
    result = context.saved do |ctx|
      ctx.should be(context)
      transform(UIng::Area::Draw::Matrix.new)
      :result
    end

    result.should eq(:result)
    context.calls.should eq([:save, :transform, :restore])
  end

  it "restores nested scopes before continuing the outer drawing block" do
    context = SavedDrawingContext.new
    context.saved do
      saved { :inner }
      transform(UIng::Area::Draw::Matrix.new)
    end

    context.calls.should eq([:save, :save, :restore, :transform, :restore])
  end

  it "restores every nested scope on exception and preserves the original error" do
    context = SavedDrawingContext.new
    original = Exception.new("drawing failed")
    error = expect_raises(Exception, original.message) do
      context.saved do
        saved do
          transform(UIng::Area::Draw::Matrix.new)
          raise original
        end
      end
    end

    error.should be(original)
    context.calls.should eq([:save, :save, :transform, :restore, :restore])
  end

  it "restores state when the block exits with break" do
    context = SavedDrawingContext.new
    result = context.saved { break :stopped }

    result.should eq(:stopped)
    context.calls.should eq([:save, :restore])
  end

  it "does not run the block or restore when saving fails" do
    context = SavedDrawingContext.new
    context.fail_save = true
    called = false
    expect_raises(Exception, "save failed") do
      context.saved { called = true }
    end

    called.should be_false
    context.calls.should eq([:save])
  end
end
