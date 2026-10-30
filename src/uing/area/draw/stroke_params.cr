module UIng
  class Area < Control
    module Draw
      class StrokeParams
        include BlockConstructor; block_constructor

        def initialize(cap : UIng::Area::Draw::LineCap = UIng::Area::Draw::LineCap::Flat,
                       join : UIng::Area::Draw::LineJoin = UIng::Area::Draw::LineJoin::Miter,
                       thickness : Number = 1.0,
                       miter_limit : Number = LibUI::DRAWDEFAULTMITERLIMIT,
                       dash_phase : Number = 0.0,
                       dashes : Enumerable(Number)? = nil)
          @cstruct = LibUI::DrawStrokeParams.new
          @dashes_array = Array(Float64).new

          self.cap = cap if cap
          self.join = join if join
          self.thickness = thickness
          self.miter_limit = miter_limit
          self.dash_phase = dash_phase
          self.dashes = dashes if dashes
        end

        # Basic properties with direct delegation
        def cap : UIng::Area::Draw::LineCap
          @cstruct.cap
        end

        def cap=(value : UIng::Area::Draw::LineCap)
          @cstruct.cap = value
        end

        def join : UIng::Area::Draw::LineJoin
          @cstruct.join
        end

        def join=(value : UIng::Area::Draw::LineJoin)
          @cstruct.join = value
        end

        def thickness : Float64
          @cstruct.thickness
        end

        def thickness=(value : Number)
          @cstruct.thickness = NumericValue.positive(value, "stroke thickness")
        end

        def miter_limit : Float64
          @cstruct.miter_limit
        end

        def miter_limit=(value : Number)
          @cstruct.miter_limit = NumericValue.finite(value, "stroke miter limit")
        end

        def dash_phase : Float64
          @cstruct.dash_phase
        end

        def dash_phase=(value : Number)
          @cstruct.dash_phase = NumericValue.finite(value, "stroke dash phase")
        end

        # Dashes property using Crystal Array
        def dashes : Array(Float64)
          @dashes_array
        end

        def dashes=(values : Array(Float64))
          values.each_with_index do |value, index|
            NumericValue.finite(value, "stroke dash #{index}")
          end
          @dashes_array = values
          sync_dashes
        end

        def dashes=(values : Enumerable(Number))
          @dashes_array = values.map_with_index do |value, index|
            NumericValue.finite(value, "stroke dash #{index}")
          end
          sync_dashes
        end

        def num_dashes : Int32
          @dashes_array.size
        end

        private def sync_dashes
          if @dashes_array.empty?
            @cstruct.dashes = Pointer(LibC::Double).null
            @cstruct.num_dashes = 0_u64
          else
            @cstruct.dashes = @dashes_array.to_unsafe.as(Pointer(LibC::Double))
            @cstruct.num_dashes = @dashes_array.size.to_u64
          end
        end

        def to_unsafe
          sync_dashes
          pointerof(@cstruct)
        end
      end
    end
  end
end
