module UIng
  private module BlockConstructor
    protected def __block_constructor_failed__ : Nil
    end

    macro block_constructor
      def self.new(*args, &block)
        instance = new(*args)
        completed = false
        begin
          with instance yield(instance)
          completed = true
          instance
        ensure
          unless completed
            begin
              instance.__block_constructor_failed__
            rescue cleanup_error
              UIng.handle_callback_error(cleanup_error, "#{instance.class} block construction cleanup")
            end
          end
        end
      end

      def self.new(*args, **kwargs, &block)
        instance = new(*args, **kwargs)
        completed = false
        begin
          with instance yield(instance)
          completed = true
          instance
        ensure
          unless completed
            begin
              instance.__block_constructor_failed__
            rescue cleanup_error
              UIng.handle_callback_error(cleanup_error, "#{instance.class} block construction cleanup")
            end
          end
        end
      end
    end
  end
end
