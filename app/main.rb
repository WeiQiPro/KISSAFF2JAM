require "app/camera.rb"
require "app/renderer.rb"
require "app/sprite_stack.rb"
require "app/object_handler.rb"
require "app/input_handler.rb"
require "app/world.rb"
require "app/kf_okarin/camera"
require "app/kf_okarin/sprite_stack"
require "app/kf_okarin/util"

WIDTH = 1280
HEIGHT = 720

def debugger args
    args.outputs.debug << " W: #{args.inputs.keyboard.key_held.w}"
    args.outputs.debug << " S: #{args.inputs.keyboard.key_held.s}"
    args.outputs.debug << " D: #{args.inputs.keyboard.key_held.d}"
    args.outputs.debug << " A: #{args.inputs.keyboard.key_held.a}"
  
    args.outputs.debug << " CPOS: #{$world.camera.position}"
    args.outputs.debug << " CVEL: #{$world.camera.velocity}"
    args.outputs.debug << " CROT: #{$world.camera.rotation}"
end

def tick(args)
    # $world ||= World.new(args)
    # $world.args = args
    # $world.update(args.inputs.keyboard)

    # args.outputs.sprites << Renderer::_sprites($world.objects)
    # args.outputs.sprites << {x: $world.camera.position.x, y: $world.camera.position.y, w: 10, h: 10, path: :pixel, r: 0, g: 0, b: 0 }
  # debugger(args)

  args.state.models ||= {
    house: build_sprite_stack_from(
      path: 'sprites/house_stack.png',
      w: 95, h: 58, sprite_count: 49
    )
  }
  args.state.objects ||= [
    { x: 0, y: 0, model: :house }
  ]
  camera = args.state.camera ||= KfOkarin::Camera.new

  perspective = camera.perspective
  mouse = args.inputs.mouse
  drag_start = args.state.drag_start
  if drag_start
    new_yaw = (drag_start[:perspective].yaw - (drag_start[:x] - mouse.x) * 0.5).to_i
    new_pitch = (drag_start[:perspective].pitch + (drag_start[:y] - mouse.y) * 0.5).to_i
    camera.perspective = drag_start[:perspective].with(
      yaw: new_yaw,
      pitch: new_pitch
    )
    args.state.drag_start = nil if mouse.up
  else
    args.state.drag_start = { x: mouse.x, y: mouse.y, perspective: perspective } if mouse.down
  end

  if mouse.wheel
    camera.perspective = camera.perspective.with(
      scale: camera.perspective.scale + mouse.wheel.y.sign
    )
  end

  args.state.objects.each do |object|
    model = args.state.models[object[:model]]
    render_args = camera.transform_object(object)
    model.render(args, **render_args)
  end

  args.outputs.debug.watch $gtk.current_framerate
  args.outputs.debug << "Pitch: #{perspective.pitch}"
  args.outputs.debug << "Yaw: #{perspective.yaw}"
  args.outputs.debug << "Scale: #{perspective.scale}"
end
