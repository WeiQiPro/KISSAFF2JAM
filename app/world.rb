class World
    attr_accessor :args, :inputs, :camera, :objects, :renderer
  
    def initialize(args)
      @width = WIDTH
      @height = HEIGHT
      @camera = Camera.new(x: 0, y: 0, z: 50, fov: 90, zfar: 100, znear: 10, angle: 0, y_offset: HEIGHT / 2, x_offset: WIDTH / 2)
      @objects = generate_objects(100)
      @input_handler = InputHandler.new(@camera)
      @object_updater = ObjectUpdater.new(@camera, @objects)
    end
  
    def generate_objects(count)
      objects = []
      count.times do
        radius = rand(2000)
        angle = rand(360)
        x = radius * Math.cos(angle * Math::PI / 180)
        y = radius * Math.sin(angle * Math::PI / 180)
  
        object = SpriteStack.new(x: x, y: y, z: 100, a: 45, stack: 49, w: 96, h: 58, source: "sprites/house_stack.png", r: rand(255), g: rand(255), b: rand(255))
        objects << object
      end
  
      objects
    end
  
    def update(inputs)
      @input_handler.handle_inputs(inputs)
      @object_updater.update_objects
    end

    def self.world_to_screen(x, y, z, camera)
        # Calculate the distance from the camera
        distance = z - camera.z
        
        # Calculate the scale based on the distance and field of view
        scale = camera.zfar / (camera.zfar - camera.znear) * camera.fov / (distance + camera.znear)
        
        # Calculate the screen x-coordinate based on the angle and distance, keeping the camera at the center of the screen
        rel_x = x + camera.x_offset + camera.x
        rel_y = y + camera.y_offset + camera.y
        screen_x = rel_x * Math.cos(camera.angle * Math::PI / 180) - rel_y * Math.sin(camera.angle * Math::PI / 180) + $WIDTH / 2
        
        # Calculate the screen y-coordinate based on the angle and distance, keeping the camera at the center of the screen
        screen_y = rel_x * Math.sin(camera.angle * Math::PI / 180) + rel_y * Math.cos(camera.angle * Math::PI / 180) + $HEIGHT / 2
        
        { x: screen_x, y: screen_y, scale: scale }
    end
end