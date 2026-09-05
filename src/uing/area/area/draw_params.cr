module UIng
  class Area < Control
    module Draw
      private class CallbackScope
        @active = true

        def invalidate : Nil
          @active = false
        end

        def check_available : Nil
          raise "Draw context is no longer available" unless @active
        end
      end

      # This class provides read-only access to area draw parameters.
      # Scalar fields are copied, but Context access is limited to the draw callback.
      class Params
        include BlockConstructor; block_constructor
        @callback_scope : CallbackScope?

        def initialize(ptr_ref : LibUI::AreaDrawParams*)
          @cstruct = ptr_ref.value
          @callback_scope = nil
        end

        protected def self.borrowed(ptr_ref : LibUI::AreaDrawParams*) : Params
          Params.new(ptr_ref, CallbackScope.new)
        end

        protected def initialize(ptr_ref : LibUI::AreaDrawParams*, @callback_scope : CallbackScope)
          @cstruct = ptr_ref.value
        end

        protected def invalidate_borrow : Nil
          @callback_scope.try &.invalidate
        end

        def context : Context
          check_context_available
          if callback_scope = @callback_scope
            Context.borrowed(@cstruct.context, callback_scope)
          else
            Context.new(@cstruct.context)
          end
        end

        def area_width : Float64
          @cstruct.area_width
        end

        def area_height : Float64
          @cstruct.area_height
        end

        def clip_x : Float64
          @cstruct.clip_x
        end

        def clip_y : Float64
          @cstruct.clip_y
        end

        def clip_width : Float64
          @cstruct.clip_width
        end

        def clip_height : Float64
          @cstruct.clip_height
        end

        def to_unsafe
          check_context_available
          pointerof(@cstruct)
        end

        private def check_context_available : Nil
          @callback_scope.try &.check_available
        end
      end
    end
  end
end
