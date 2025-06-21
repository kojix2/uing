module UIng
  class Area < Control
    module Draw
      class StrokeParams
        def initialize(cap : UIng::Area::Draw::LineCap? = nil,
                       join : UIng::Area::Draw::LineJoin? = nil,
                       thickness : Number? = nil,
                       miter_limit : Number? = nil,
                       dash_phase : Number? = nil,
                       dashes : Enumerable(Float64)? = nil)
          @cstruct = LibUI::DrawStrokeParams.new
          @dashes_array = Array(Float64).new

          self.cap = cap if cap
          self.join = join if join
          self.thickness = thickness if thickness
          self.miter_limit = miter_limit if miter_limit
          self.dash_phase = dash_phase if dash_phase
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
          @cstruct.thickness = value.to_f64
        end

        def miter_limit : Float64
          @cstruct.miter_limit
        end

        def miter_limit=(value : Number)
          @cstruct.miter_limit = value.to_f64
        end

        def dash_phase : Float64
          @cstruct.dash_phase
        end

        def dash_phase=(value : Number)
          @cstruct.dash_phase = value.to_f64
        end

        # Dashes property using Crystal Array
        def dashes : Array(Float64)
          @dashes_array
        end

        def dashes=(values : Array(Float64))
          @dashes_array = values
          sync_dashes
        end

        def dashes=(values : Enumerable(Float64))
          @dashes_array = values.to_a
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
