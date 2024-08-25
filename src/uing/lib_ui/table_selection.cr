module UIng
  lib LibUI
    struct TableSelection
      num_rows : LibC::Int
      rows : Pointer(LibC::Int)
    end
  end
end
