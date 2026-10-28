module UIng
  lib LibUI
    enum DropFormat : UInt32
      None  = 0
      Text  = 1
      Files = 2
    end

    struct DropInfo
      formats : LibC::UInt
      format : DropFormat
      x : LibC::Double
      y : LibC::Double
    end

    struct DropData
      format : DropFormat
      text : Pointer(LibC::Char)
      text_length : LibC::SizeT
      files : Pointer(Pointer(LibC::Char))
      file_count : LibC::SizeT
    end

    enum DropAction : UInt32
      None = 0
      Copy = 1
    end

    enum DropResult : UInt32
      Rejected = 0
      Accepted = 1
    end

    enum DropStatus : UInt32
      OK              = 0
      InvalidArgument = 1
      Unavailable     = 2
      NativeError     = 3
    end

    struct DropHandler
      size : LibC::SizeT
      drop : (Pointer(DropInfo), Pointer(DropData), Pointer(Void) -> DropResult)
      over : (Pointer(DropInfo), Pointer(Void) -> DropAction)
      leave : (Pointer(Void) -> Void)
      release_user_data : (Pointer(Void) -> Void)
    end
  end
end
