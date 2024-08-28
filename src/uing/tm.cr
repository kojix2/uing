module UIng
  class TM
    def initialize(@cstruct : LibUI::TM = LibUI::TM.new)
    end

    {% unless flag?(:windows) %}
      def zone
        String.new(@cstruct.zone)
      end

      def zone=(value : String)
        @zone = value
        @cstruct.zone = @zone.to_unsafe
      end
    {% end %}

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
