# Minimal 2D vector for table-space movement. It is named Vec2 even though the
# second component is z because the table is simulated from above.
struct Vec2
  property x : Float64
  property z : Float64

  def initialize(@x : Float64, @z : Float64)
  end

  def +(other : Vec2) : Vec2
    Vec2.new(@x + other.x, @z + other.z)
  end

  def -(other : Vec2) : Vec2
    Vec2.new(@x - other.x, @z - other.z)
  end

  def *(other : Float64) : Vec2
    Vec2.new(@x * other, @z * other)
  end

  def /(other : Float64) : Vec2
    return Vec2.new(0.0, 0.0) if other.abs <= AirHockey3DConfig::EPSILON

    Vec2.new(@x / other, @z / other)
  end

  def length : Float64
    Math.sqrt(@x * @x + @z * @z)
  end

  def normalized : Vec2
    len = length
    return Vec2.new(0.0, 0.0) if len <= AirHockey3DConfig::EPSILON
    self / len
  end

  def dot(other : Vec2) : Float64
    @x * other.x + @z * other.z
  end

  def limit(max : Float64) : Vec2
    return Vec2.new(0.0, 0.0) if max <= 0.0

    len = length
    return self if len <= max
    normalized * max
  end
end
