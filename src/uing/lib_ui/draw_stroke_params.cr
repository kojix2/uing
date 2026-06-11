module UIng
  lib LibUI
    struct DrawStrokeParams
      cap : UIng::Area::Draw::LineCap
      join : UIng::Area::Draw::LineJoin
      thickness : LibC::Double
      miter_limit : LibC::Double
      dashes : Pointer(LibC::Double)
      num_dashes : LibC::SizeT
      dash_phase : LibC::Double
    end
  end
end
