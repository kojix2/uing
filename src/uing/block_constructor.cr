module UIng
  module BlockConstructor
    macro block_constructor
      def self.new(*args, &block)
        instance = new(*args)
        with instance yield
        instance
      end

      def self.new(*args, **kwargs, &block)
        instance = new(*args, **kwargs)
        with instance yield(instance)
        instance
      end
    end
  end
end
