require "../../../spec_helper"
require "../../../support/native_wrappers"

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
  it "invalidates draw parameters and contexts after the callback" do
    draw_params = UIng::LibUI::AreaDrawParams.new(
      context: Pointer(UIng::LibUI::DrawContext).null,
      area_width: 640.0,
      area_height: 480.0,
      clip_x: 0.0,
      clip_y: 0.0,
      clip_width: 640.0,
      clip_height: 480.0
    )
    saved_params = nil
    saved_context = nil
    handler = UIng::Area::Handler.new
    handler.draw do |_area, params|
      saved_params = params
      saved_context = params.context do |context|
        to_unsafe.should eq(context.to_unsafe)
        context.to_unsafe.should eq(params.context.to_unsafe)
        context
      end
      typeof(params.context do
        saved do
          fill_path(UIng::Area::Draw::Brush.new(:solid)) do
            add_rectangle(0, 0, 10, 10)
          end
        end
      end).should eq(Nil)
    end

    handler_ptr = handler.to_unsafe
    handler_ptr.value.draw.call(
      handler_ptr,
      Pointer(UIng::LibUI::Area).null,
      pointerof(draw_params)
    )

    params = saved_params.should_not be_nil
    context = saved_context.should_not be_nil
    expect_raises(Exception, /no longer available/) { params.context }
    expect_raises(Exception, /no longer available/) { params.context { to_unsafe } }
    expect_raises(Exception, /no longer available/) { params.to_unsafe }
    expect_raises(Exception, /no longer available/) { context.to_unsafe }
    expect_raises(Exception, /no longer available/) { context.saved { raise "must not draw" } }
    params.area_width.should eq(640.0)
  end

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

  it "supports implicit Path receivers and existing block forms in path builders" do
    context = UIng::Area::Draw::Context.from_native_for_spec(Pointer(UIng::LibUI::DrawContext).null)
    brush = UIng::Area::Draw::Brush.new(:solid)
    stroke = UIng::Area::Draw::StrokeParams.new

    # Instantiate the drawing blocks without calling libui-ng with a null context.
    typeof(context.fill_path(brush) { add_rectangle(0, 0, 10, 10) }).should eq(Nil)
    typeof(context.stroke_path(brush) { new_figure(0, 0); line_to(10, 10) }).should eq(Nil)
    typeof(context.stroke_path(brush, stroke) { new_figure(0, 0); line_to(10, 10) }).should eq(Nil)
    typeof(context.clip_path { add_rectangle(0, 0, 10, 10) }).should eq(Nil)
    typeof(context.draw_path(fill_brush: brush) { add_rectangle(0, 0, 10, 10) }).should eq(Nil)

    # Keep an explicit block argument to cover the existing non-DSL form.
    # ameba:disable Style/VerboseBlock
    typeof(context.fill_path(brush) { |path| path.add_rectangle(0, 0, 10, 10) }).should eq(Nil)
    # ameba:enable Style/VerboseBlock
    builder = ->(path : UIng::Area::Draw::Path) { path.add_rectangle(0, 0, 10, 10); nil }
    typeof(context.stroke_path(brush, &builder)).should eq(Nil)
  end

  it "rejects non-finite image drawing geometry before calling libui-ng" do
    context = UIng::Area::Draw::Context.from_native_for_spec(Pointer(UIng::LibUI::DrawContext).null)
    image = UIng::Image.from_native_for_spec(Pointer(UIng::LibUI::Image).null)

    expect_raises(ArgumentError, /draw x must be finite/) do
      context.draw_image(image, Float64::NAN, 0, 1, 1)
    end
    expect_raises(ArgumentError, /draw y must be finite/) do
      context.draw_image(image, 0, Float64::INFINITY, 1, 1)
    end
    expect_raises(ArgumentError, /draw width must be finite and positive/) do
      context.draw_image(image, 0, 0, Float64::INFINITY, 1)
    end
    expect_raises(ArgumentError, /draw height must be finite and positive/) do
      context.draw_image(image, 0, 0, 1, 0)
    end
  end
end
