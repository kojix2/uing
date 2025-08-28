require "../../src/uing"

UIng.init

module Config
  WINDOW_WIDTH  =   800
  WINDOW_HEIGHT =   450
  AREA_SIZE     = 360.0
  STAR_SIZE     =  50.0
  GRID_STEP     =    20
  CENTER        = {x: AREA_SIZE / 2.0, y: AREA_SIZE / 2.0}
end

# Common slider conversion (0..1000 ⇄ actual values)
module SliderMap
  extend self

  def to_slider(min : Float64, max : Float64, v : Float64) : Int32
    ((v - min) / (max - min) * 1000.0).clamp(0.0, 1000.0).round.to_i
  end

  def from_slider(min : Float64, max : Float64, i : Int32) : Float64
    min + (i.to_f64 / 1000.0) * (max - min)
  end
end

struct StarTransform
  property translate_x : Float64 = 0.0
  property translate_y : Float64 = 0.0
  property scale_x : Float64 = 1.0
  property scale_y : Float64 = 1.0
  # Internal representation is in radians
  property rotation : Float64 = 0.0
  property skew_x : Float64 = 0.0
  property skew_y : Float64 = 0.0

  def translation
    {x: @translate_x, y: @translate_y}
  end

  def scale
    {x: @scale_x, y: @scale_y}
  end

  def reset!
    @translate_x = @translate_y = 0.0
    @scale_x = @scale_y = 1.0
    @rotation = @skew_x = @skew_y = 0.0
  end

  def to_matrix : UIng::Area::Draw::Matrix
    center = Config::CENTER
    cx = center[:x] + @translate_x
    cy = center[:y] + @translate_y

    UIng::Area::Draw::Matrix.new.tap do |m|
      m.set_identity
      m.translate(cx, cy)
      m.scale(cx, cy, @scale_x, @scale_y)
      m.rotate(cx, cy, @rotation)
      m.skew(cx, cy, @skew_x, @skew_y)
    end
  end
end

# Reusable drawing resources created once
struct PaintKit
  getter bg_brush : UIng::Area::Draw::Brush
  getter grid_brush : UIng::Area::Draw::Brush
  getter grid_stroke : UIng::Area::Draw::StrokeParams
  getter star_fill : UIng::Area::Draw::Brush
  getter star_stroke : UIng::Area::Draw::StrokeParams
  getter star_outline : UIng::Area::Draw::Brush
  getter center_brush : UIng::Area::Draw::Brush

  def initialize
    @bg_brush = UIng::Area::Draw::Brush.new(:solid, 0.96, 0.97, 1.0, 1.0)
    @grid_brush = UIng::Area::Draw::Brush.new(:solid, 0.86, 0.88, 0.92, 1.0)
    @grid_stroke = UIng::Area::Draw::StrokeParams.new.tap { |s| s.thickness = 1.0 }

    @star_fill = UIng::Area::Draw::Brush.new(:solid, 1.0, 0.82, 0.0, 0.85)
    @star_stroke = UIng::Area::Draw::StrokeParams.new.tap { |s| s.thickness = 3.0 }
    @star_outline = UIng::Area::Draw::Brush.new(:solid, 0.85, 0.45, 0.05, 1.0)

    @center_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 0.15, 0.2, 1.0)
  end
end

class StarMatrixDemo
  @window : UIng::Window
  @area : UIng::Area
  @star_transform : StarTransform

  # UI components
  @sliders : Hash(String, UIng::Slider)
  @labels : Hash(String, UIng::Label)

  # Slider specifications (min/max/initial value/display function)
  struct Spec
    getter min, max, init
    getter fmt : Proc(Float64, String)

    def initialize(@min : Float64, @max : Float64, @init : Float64, @fmt : Proc(Float64, String)); end
  end

  @specs : Hash(String, Spec)

  # Reusable drawing resources
  @paint : PaintKit
  @grid_path : UIng::Area::Draw::Path?
  @star_path_origin : UIng::Area::Draw::Path?
  @star_path_center : UIng::Area::Draw::Path?

  def initialize
    @star_transform = StarTransform.new
    @sliders = {} of String => UIng::Slider
    @labels = {} of String => UIng::Label
    @specs = build_specs
    @paint = PaintKit.new

    @window = create_window
    @area = create_area

    # Pre-generate paths for performance optimization
    @grid_path = build_grid_path
    @star_path_origin = build_star_path(0.0, 0.0, Config::STAR_SIZE)
    @star_path_center = build_star_path(Config::CENTER[:x], Config::CENTER[:y], Config::STAR_SIZE)

    setup_ui
  end

  def finalize
    # Memory management: properly free paths
    @grid_path.try(&.free)
    @star_path_origin.try(&.free)
    @star_path_center.try(&.free)
  end

  private def build_specs : Hash(String, Spec)
    {
      # Display in degrees (internal is radians) - fixed width display
      "rotation"    => Spec.new(-Math::PI, Math::PI, 0.0, ->(v : Float64) { "R: #{(v * 180.0 / Math::PI).round.to_i.to_s.ljust(4)}" }),
      "translate_x" => Spec.new(-200.0, 200.0, 0.0, ->(v : Float64) { "X: #{v.round(2).to_s.ljust(7)}" }),
      "translate_y" => Spec.new(-200.0, 200.0, 0.0, ->(v : Float64) { "Y: #{v.round(2).to_s.ljust(7)}" }),
      "scale_x"     => Spec.new(0.1, 3.0, 1.0, ->(v : Float64) { "X: #{v.round(2).to_s.ljust(4)}" }),
      "scale_y"     => Spec.new(0.1, 3.0, 1.0, ->(v : Float64) { "Y: #{v.round(2).to_s.ljust(4)}" }),
      "skew_x"      => Spec.new(-1.0, 1.0, 0.0, ->(v : Float64) { "X: #{v.round(2).to_s.ljust(5)}" }),
      "skew_y"      => Spec.new(-1.0, 1.0, 0.0, ->(v : Float64) { "Y: #{v.round(2).to_s.ljust(5)}" }),
    } of String => Spec
  end

  private def create_window : UIng::Window
    w = UIng::Window.new("Area Matrix Transformations Example",
      Config::WINDOW_WIDTH, Config::WINDOW_HEIGHT, margined: true)
    w.on_closing { UIng.quit; true }
    w
  end

  private def create_area : UIng::Area
    handler = UIng::Area::Handler.new
    handler.draw { |_, params| draw_scene(params.context) }
    UIng::Area.new(handler)
  end

  private def setup_ui : Nil
    main_box = UIng::Box.new(:horizontal, padded: true)
    control_panel = create_control_panel

    main_box.append(control_panel, stretchy: true)
    main_box.append(@area, stretchy: true)
    @window.child = main_box
  end

  private def create_control_panel : UIng::Box
    box = UIng::Box.new(:vertical, padded: true)
    box.append(UIng::Label.new("Matrix Transformations"), stretchy: false)

    box.append(UIng::Label.new("Translation:"), stretchy: false)
    add_slider(box, "translate_x")
    add_slider(box, "translate_y")

    box.append(UIng::Separator.new(:horizontal), stretchy: false)

    box.append(UIng::Label.new("Scale:"), stretchy: false)
    add_slider(box, "scale_x")
    add_slider(box, "scale_y")

    box.append(UIng::Separator.new(:horizontal), stretchy: false)

    box.append(UIng::Label.new("Rotation:"), stretchy: false)
    add_slider(box, "rotation")

    box.append(UIng::Separator.new(:horizontal), stretchy: false)

    box.append(UIng::Label.new("Skew:"), stretchy: false)
    add_slider(box, "skew_x")
    add_slider(box, "skew_y")

    box.append(UIng::Separator.new(:horizontal), stretchy: false)

    reset = UIng::Button.new("Reset All")
    reset.on_clicked { reset_transforms }
    box.append(reset, stretchy: false)
    box
  end

  private def add_slider(parent : UIng::Box, key : String) : Nil
    spec = @specs[key]?
    raise "unknown slider: #{key}" unless spec

    container = UIng::Box.new(:horizontal, padded: true)
    label = UIng::Label.new(spec.fmt.call(spec.init))
    @labels[key] = label
    container.append(label, stretchy: false)

    slider = UIng::Slider.new(0, 1000)
    slider.value = SliderMap.to_slider(spec.min, spec.max, spec.init)
    slider.on_changed do
      v = SliderMap.from_slider(spec.min, spec.max, slider.value)
      update_transform(key, v)
      @labels[key].text = spec.fmt.call(v)
      @area.queue_redraw_all
    end

    @sliders[key] = slider
    container.append(slider, stretchy: true)
    parent.append(container, stretchy: false)
  end

  private def update_transform(key : String, value : Float64) : Nil
    case key
    when "translate_x" then @star_transform.translate_x = value
    when "translate_y" then @star_transform.translate_y = value
    when "scale_x"     then @star_transform.scale_x = value
    when "scale_y"     then @star_transform.scale_y = value
    when "rotation"    then @star_transform.rotation = value
    when "skew_x"      then @star_transform.skew_x = value
    when "skew_y"      then @star_transform.skew_y = value
    end
  end

  private def reset_transforms : Nil
    @star_transform.reset!
    # Reset sliders/labels from specifications
    @specs.each do |key, spec|
      if slider = @sliders[key]?
        slider.value = SliderMap.to_slider(spec.min, spec.max, spec.init)
      end
      if label = @labels[key]?
        label.text = spec.fmt.call(spec.init)
      end
    end
    @area.queue_redraw_all
  end

  private def draw_scene(ctx : UIng::Area::Draw::Context) : Nil
    draw_background(ctx)
    draw_grid(ctx)
    draw_center_point(ctx)
    draw_original_star(ctx)
    draw_transformed_star(ctx)
  end

  private def draw_background(ctx : UIng::Area::Draw::Context) : Nil
    ctx.fill_path(@paint.bg_brush) do |p|
      p.add_rectangle(0, 0, Config::AREA_SIZE, Config::AREA_SIZE)
    end
  end

  private def build_grid_path : UIng::Area::Draw::Path
    path = UIng::Area::Draw::Path.new(:winding)
    # Vertical and horizontal lines
    (0..Config::AREA_SIZE.to_i).step(Config::GRID_STEP) do |t|
      x = t.to_f64
      y = t.to_f64
      path.new_figure(x, 0.0)
      path.line_to(x, Config::AREA_SIZE)
      path.new_figure(0.0, y)
      path.line_to(Config::AREA_SIZE, y)
    end
    path.end_path
    path
  end

  private def draw_grid(ctx : UIng::Area::Draw::Context) : Nil
    if grid_path = @grid_path
      ctx.draw_stroke(grid_path, @paint.grid_brush, @paint.grid_stroke)
    end
  end

  private def build_star_path(cx : Float64, cy : Float64, size : Float64) : UIng::Area::Draw::Path
    outer = size
    inner = size * 0.4
    pts = Array(Tuple(Float64, Float64)).new(10)
    10.times do |i|
      ang = (i * Math::PI / 5.0) - Math::PI / 2.0
      r = i.even? ? outer : inner
      pts << {cx + r * Math.cos(ang), cy + r * Math.sin(ang)}
    end
    path = UIng::Area::Draw::Path.new(:winding)
    path.new_figure(pts[0][0], pts[0][1])
    pts[1..].each { |(x, y)| path.line_to(x, y) }
    path.close_figure
    path.end_path
    path
  end

  private def draw_original_star(ctx : UIng::Area::Draw::Context) : Nil
    # Gray guide (stroke only, low alpha)
    guide = UIng::Area::Draw::Brush.new(:solid, 0.55, 0.55, 0.60, 0.35)
    stroke = UIng::Area::Draw::StrokeParams.new.tap { |s| s.thickness = 2.0 }
    if star_path = @star_path_center
      ctx.draw_stroke(star_path, guide, stroke)
    end
  end

  private def draw_transformed_star(ctx : UIng::Area::Draw::Context) : Nil
    ctx.transform(@star_transform.to_matrix)
    if star_path = @star_path_origin
      ctx.draw_fill(star_path, @paint.star_fill)
      ctx.draw_stroke(star_path, @paint.star_outline, @paint.star_stroke)
    end
  end

  private def draw_center_point(ctx : UIng::Area::Draw::Context) : Nil
    ctx.fill_path(@paint.center_brush) do |p|
      p.new_figure_with_arc(Config::CENTER[:x], Config::CENTER[:y], 3.0, 0.0, Math::PI * 2, false)
    end
  end

  def run : Nil
    @window.show
    UIng.main
  end
end

demo = StarMatrixDemo.new
demo.run
