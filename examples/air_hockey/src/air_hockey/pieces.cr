module AirHockey
  class Mallet
    property position : Vec2
    property previous : Vec2
    property velocity : Vec2
    property radius : Float64

    def initialize(@position : Vec2, @radius : Float64 = Config::MALLET_R)
      @previous = @position
      @velocity = Vec2.new(0.0, 0.0)
    end

    # Move toward a target, capped to max_step so mouse jumps and AI decisions do
    # not teleport the mallet. Velocity is measured in "pixels per tick" and later
    # becomes part of the collision impulse.
    def move_to(target : Vec2, max_step : Float64, x_limit : Float64, z_min : Float64, z_max : Float64)
      @previous = @position
      limited = (target - @position).limit(max_step)
      next_position = @position + limited
      @position = Vec2.new(
        next_position.x.clamp(-x_limit, x_limit),
        next_position.z.clamp(z_min, z_max)
      )
      @velocity = @position - @previous
    end
  end

  class Puck
    property position : Vec2
    property velocity : Vec2
    property radius : Float64

    def initialize(@position : Vec2, @radius : Float64 = Config::PUCK_R)
      @velocity = Vec2.new(0.0, 0.0)
    end

    def speed : Float64
      @velocity.length
    end
  end
end
