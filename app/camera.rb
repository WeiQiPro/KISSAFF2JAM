class Camera
    attr_accessor :x, :y, :z, :fov, :zfar, :znear, :angle, :y_offset, :x_offset, :velocity, :position, :rotation
  
    def initialize(x:, y:, z:, fov:, zfar:, znear:, angle:, y_offset:, x_offset:)
      @velocity = { x: 0, y: 0 }
      @position = { x: x + x_offset, y: y + y_offset }
      @z = z
      @fov = fov
      @zfar = zfar
      @znear = znear
      @angle = angle
      @rotation = 0
      @y_offset = y_offset
      @x_offset = x_offset
    end
  end