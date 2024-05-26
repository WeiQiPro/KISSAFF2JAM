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
      { x: 640, y: 360, perspective: @perspective }
    end
  end
end
