module UIng
  # Converts public numeric inputs to the native Float64 representation and
  # rejects values that libui-ng cannot handle safely.
  private module NumericValue
    extend self

    def finite(value : Number, name : String) : Float64
      converted = convert(value, name)
      raise ArgumentError.new("#{name} must be finite") unless converted.finite?
      converted
    end

    def positive(value : Number, name : String) : Float64
      converted = convert(value, name)
      unless converted.finite? && converted > 0
        raise ArgumentError.new("#{name} must be finite and positive")
      end
      converted
    end

    def unit_interval(value : Number, name : String) : Float64
      converted = convert(value, name)
      unless converted.finite? && 0.0 <= converted <= 1.0
        raise ArgumentError.new("#{name} must be finite and between 0 and 1")
      end
      converted
    end

    private def convert(value : Number, name : String) : Float64
      value.to_f64
    rescue ArgumentError | OverflowError
      raise ArgumentError.new("#{name} must be representable as Float64")
    end
  end
end
