module UIng
  module Drop
    @[Flags]
    enum Format : UInt32
      Text  = 1
      Files = 2
    end

    # A snapshot of an offer. Area coordinates include document scrolling;
    # Window coordinates use its local content-size units.
    class Info
      getter formats : Format
      getter format : Format
      getter x : Float64
      getter y : Float64

      protected def initialize(info : LibUI::DropInfo)
        @formats = Format.new(info.formats)
        @format = Format.new(info.format.value)
        @x = info.x
        @y = info.y
      end
    end

    # Received text or paths copied into Crystal memory. The event and its
    # data may be retained after the callback. Paths may name directories and
    # may contain non-UTF-8 bytes on Unix; no file I/O is performed.
    class Event < Info
      getter text : String?
      @files : Array(String)?

      protected def initialize(info : LibUI::DropInfo, payload : LibUI::DropData)
        super(info)
        case payload.format
        when .text?
          @text = String.new(payload.text, payload.text_length.to_i)
        when .files?
          @files = Array(String).new(payload.file_count.to_i) do |index|
            String.new(payload.files[index])
          end
        end
      end

      def files : Array(String)?
        @files.try &.dup
      end
    end
  end
end
