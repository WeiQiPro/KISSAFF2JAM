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
      transformed = @perspective.transform_coordinates(
        x: object[:x] - @center_x,
        y: object[:y] - @center_y,
      )
      {
        x: 640 + transformed[:x],
        y: 360 + transformed[:y],
        perspective: @perspective
      }
    end
  end
end
