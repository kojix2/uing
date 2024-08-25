module UIng
  lib LibUI
    struct DrawStrokeParams
      cap : DrawLineCap
      join : DrawLineJoin
      thickness : LibC::Double
      miter_limit : LibC::Double
      dashes : Pointer(LibC::Double)
      num_dashes : LibC::SizeT
      dash_phase : LibC::Double
    end
  end
end
