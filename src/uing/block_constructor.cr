module UIng
  private module BlockConstructor
    protected def __block_constructor_failed__ : Nil
    end

    macro block_constructor
      def self.new(*args, &block)
        instance = new(*args)
        begin
          with instance yield(instance)
        rescue error
          begin
            instance.__block_constructor_failed__
          rescue cleanup_error
            UIng.handle_callback_error(cleanup_error, "#{instance.class} block construction cleanup")
          end
          raise error
        end
        instance
      end

      def self.new(*args, **kwargs, &block)
        instance = new(*args, **kwargs)
        begin
          with instance yield(instance)
        rescue error
          begin
            instance.__block_constructor_failed__
          rescue cleanup_error
            UIng.handle_callback_error(cleanup_error, "#{instance.class} block construction cleanup")
          end
          raise error
        end
        instance
      end
    end
  end
end
