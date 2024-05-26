module KfOkarin
  class Perspective
    attr_reader :yaw, :pitch, :scale

    def initialize(yaw: 0, pitch: 30, scale: 1)
      # convert yaw to range -180..180
      @yaw = (yaw + 180) % 360 - 180
      @yaw_sin = Math.sin(@yaw.to_radians)
      @yaw_cos = Math.cos(@yaw.to_radians)
      @pitch = pitch.clamp(15, 90)
      @pitch_sin = Math.sin(@pitch.to_radians)
      @pitch_cos = Math.cos(@pitch.to_radians)
      @scale = [1, scale].max.to_i
    end

    def with(yaw: nil, pitch: nil, scale: nil)
      self.class.new(
        yaw: yaw || @yaw,
        pitch: pitch || @pitch,
        scale: scale || @scale
      )
    end

    def rotate_coordinates(x:, y:)
      {
        x: x * @yaw_cos - y * @yaw_sin,
        y: x * @yaw_sin + y * @yaw_cos
      }
    end

    def unrotate_coordinates(x:, y:)
      {
        x: x * @yaw_cos + y * @yaw_sin,
        y: -x * @yaw_sin + y * @yaw_cos
      }
    end

    def transform_coordinates(x:, y:, z: 0)
      rotated = rotate_coordinates(x: x, y: y)
      y = transform_y_distance(rotated[:y])
      y += transform_z_distance(z) if z != 0
      {
        x: transform_x_distance(rotated[:x]),
        y: y
      }
    end

    def transform_x_distance(x)
      x * @scale
    end

    def transform_y_distance(y)
      y * @scale * @pitch_sin
    end

    def transform_z_distance(z)
      z * @scale * @pitch_cos
    end
  end
end
