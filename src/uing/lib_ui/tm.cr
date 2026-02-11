module UIng
  lib LibUI
    {% if flag?(:windows) %}
      struct TM
        sec : LibC::Int
        min : LibC::Int
        hour : LibC::Int
        mday : LibC::Int
        mon : LibC::Int
        year : LibC::Int
        wday : LibC::Int
        yday : LibC::Int
        isdst : LibC::Int
      end
    {% else %}
      struct TM
        sec : LibC::Int
        min : LibC::Int
        hour : LibC::Int
        mday : LibC::Int
        mon : LibC::Int
        year : LibC::Int
        wday : LibC::Int
        yday : LibC::Int
        isdst : LibC::Int
        gmtoff : LibC::Long
        zone : Pointer(LibC::Char)
      end
    {% end %}
  end
end
