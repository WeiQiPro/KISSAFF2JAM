require_relative 'perspective'

module KfOkarin
  class Camera
    attr_accessor :perspective

    def initialize
      @center_x = 0
      @center_y = 0
      @perspective = Perspective.new(scale: 4, pitch: 20, yaw: 100)
    end

    def transform_object(object)
      pitch_sin = Math.sin(@perspective.pitch.to_radians)
      relative_x = object[:x] - @center_x
      relative_y = object[:y] - @center_y
      yaw_sin = Math.sin(@perspective.yaw.to_radians)
      yaw_cos = Math.cos(@perspective.yaw.to_radians)
      rotated_x = relative_x * yaw_cos - relative_y * yaw_sin
      rotated_y = relative_x * yaw_sin + relative_y * yaw_cos
      {
        x: 640 + rotated_x * @perspective.scale,
        y: 360 + (rotated_y * @perspective.scale) * pitch_sin,
        perspective: @perspective
      }
    end
  end
end
