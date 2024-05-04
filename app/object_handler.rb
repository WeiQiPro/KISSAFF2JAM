class ObjectUpdater
    def initialize(camera, objects)
      @camera = camera
      @objects = objects
    end
  
    def update_objects
      @objects.each do |object|
        # Move the object in the opposite direction of the camera's velocity
        object.x -= @camera.velocity.x
        object.y -= @camera.velocity.y
  
        # Rotate the object around the camera's position
        dx = object.x - @camera.position.x
        dy = object.y - @camera.position.y
  
        dx, dy = rotate_point(dx, dy, 0, 0, @camera.angle)
  
        object.x = @camera.position.x + dx
        object.y = @camera.position.y + dy
      end
    end
  
    private
  
    def rotate_point(x, y, cx, cy, angle)
      radians = angle * Math::PI / 180
      new_x = Math.cos(radians) * (x - cx) - Math.sin(radians) * (y - cy) + cx
      new_y = Math.sin(radians) * (x - cx) + Math.cos(radians) * (y - cy) + cy
      [new_x, new_y]
    end
  end