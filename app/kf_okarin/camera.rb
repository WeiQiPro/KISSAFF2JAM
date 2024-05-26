require_relative 'perspective'

module KfOkarin
  class Camera
    attr_accessor :perspective, :center

    def initialize
      @center = { x: 0, y: 0 }
      @perspective = Perspective.new(scale: 4, pitch: 20, yaw: 100)
    end

    def transform_object(object)
      transformed = @perspective.transform_coordinates(
        x: object[:x] - @center[:x],
        y: object[:y] - @center[:y]
      )
      object.merge(
        x: 640 + transformed[:x],
        y: 360 + transformed[:y]
      )
    end

    def move_forward(distance)
      forward_vector = @perspective.unrotate_coordinates(x: 0, y: 1)
      @center[:x] += forward_vector[:x] * distance
      @center[:y] += forward_vector[:y] * distance
    end

    def move_right(distance)
      right_vector = @perspective.unrotate_coordinates(x: 1, y: 0)
      @center[:x] += right_vector[:x] * distance
      @center[:y] += right_vector[:y] * distance
    end
  end
end
