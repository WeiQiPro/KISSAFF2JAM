require "app/camera.rb"
require "app/renderer.rb"
require "app/sprite_stack.rb"
require "app/object_handler.rb"
require "app/input_handler.rb"
require "app/world.rb"
require "app/kf_okarin/perspective"
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

  args.state.house ||= build_sprite_stack_from(
    path: 'sprites/house_stack.png',
    w: 95, h: 58, sprite_count: 49
  )
  args.state.perspective ||= KfOkarin::Perspective.new(scale: 4, pitch: 20, yaw: 100)

  mouse = args.inputs.mouse
  if args.state.drag_start
    new_yaw = (args.state.drag_start[:perspective].yaw - (args.state.drag_start[:x] - mouse.x) * 0.5).to_i
    new_pitch = (args.state.drag_start[:perspective].pitch + (args.state.drag_start[:y] - mouse.y) * 0.5).to_i
    args.state.perspective = KfOkarin::Perspective.new(
      scale: args.state.drag_start[:perspective].scale,
      yaw: new_yaw,
      pitch: new_pitch
    )
    args.state.drag_start = nil if mouse.up
  else
    args.state.drag_start = { x: mouse.x, y: mouse.y, perspective: args.state.perspective } if mouse.down
  end

  if mouse.wheel
    args.state.perspective = KfOkarin::Perspective.new(
      scale: args.state.perspective.scale + mouse.wheel.y.sign,
      yaw: args.state.perspective.yaw,
      pitch: args.state.perspective.pitch
    )
  end

  args.state.house.render(args, x: 640, y: 360, perspective: args.state.perspective)

  args.outputs.debug.watch $gtk.current_framerate
  args.outputs.debug << "Pitch: #{args.state.perspective.pitch}"
  args.outputs.debug << "Yaw: #{args.state.perspective.yaw}"
  args.outputs.debug << "Scale: #{args.state.perspective.scale}"
end
