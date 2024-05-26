module KfOkarin
  class Perspective
    attr_reader :yaw, :pitch, :scale

    def initialize(yaw: 0, pitch: 30, scale: 1)
      # convert yaw to range -180..180
      @yaw = (yaw + 180) % 360 - 180
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

    def transform_y_distance(y)
      y * @scale * @pitch_sin
    end

    def transform_z_distance(z)
      z * @scale * @pitch_cos
    end
  end
end
