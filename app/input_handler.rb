class InputHandler
    def initialize(camera)
      @camera = camera
    end
  
    def handle_inputs(inputs)
      translation_velocity = 5
      rotation_velocity = 0.5
  
      @camera.velocity.y = inputs.key_held.w ? translation_velocity : inputs.key_held.s ?  -translation_velocity : 0
      @camera.velocity.x = inputs.key_held.d ? translation_velocity : inputs.key_held.a ?  -translation_velocity : 0
  
      @camera.angle = inputs.key_held.left_arrow ? rotation_velocity : inputs.key_held.right_arrow ? -rotation_velocity : 0
  
      @camera.rotation += @camera.angle
      @camera.rotation %= 360
    end
  end