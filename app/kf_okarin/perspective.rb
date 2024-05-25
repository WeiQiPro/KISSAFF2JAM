module KfOkarin
  class Perspective
    attr_reader :yaw, :pitch, :scale

    def initialize(yaw: 0, pitch: 30, scale: 1)
      # convert yaw to range -180..180
      @yaw = (yaw + 180) % 360 - 180
      @pitch = pitch.clamp(15, 90)
      @scale = [1, scale].max.to_i
    end
  end
end
