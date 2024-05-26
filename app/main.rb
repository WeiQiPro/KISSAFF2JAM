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

  args.state.debug_settings ||= {
    grid_visible: false
  }
  args.state.grid_size ||= 50
  args.state.objects ||= 12.times.map { |i|
    angle = i * 30
    {
      x: Math.cos(angle.to_radians) * 200,
      y: Math.sin(angle.to_radians) * 200,
      model: build_house_model,
      angle: angle
    }
  }
  camera = args.state.camera ||= KfOkarin::Camera.new

  handle_update_perpective(args)
  handle_movement(args)
  handle_debug_settings(args)

  render_grid(args, size: args.state.grid_size) if args.state.debug_settings[:grid_visible]

  transformed_objects = args.state.objects.map { |object|
    camera.transform_object(object)
  }.sort_by { |object| -object[:y] }
  transformed_objects.each do |object|
    object[:model].render(
      args,
      x: object[:x],
      y: object[:y],
      perspective: camera.perspective.with(yaw: object[:angle] + camera.perspective.yaw)
    )
  end

  perspective = camera.perspective
  args.outputs.debug.watch $gtk.current_framerate
  args.outputs.debug << 'Camera Center: %.2f, %.2f' % [camera.center[:x], camera.center[:y]]
  args.outputs.debug << "Pitch: #{perspective.pitch}"
  args.outputs.debug << "Yaw: #{perspective.yaw}"
  args.outputs.debug << "Scale: #{perspective.scale}"
  args.outputs.debug << "(G)rid visible: #{args.state.debug_settings[:grid_visible]}"
end

def build_house_model
  build_sprite_stack_from(
    path: 'sprites/house_stack.png',
    w: 95, h: 58, sprite_count: 49
  )
end

def handle_update_perpective(args)
  camera = args.state.camera
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
end

def handle_movement(args)
  camera = args.state.camera
  keyboard = args.inputs.keyboard
  if keyboard.key_held.w
    camera.move_forward(1)
  elsif keyboard.key_held.s
    camera.move_forward(-1)
  end

  if keyboard.key_held.d
    camera.move_right(1)
  elsif keyboard.key_held.a
    camera.move_right(-1)
  end
end

def handle_debug_settings(args)
  keyboard = args.inputs.keyboard
  if keyboard.key_down.g
    args.state.debug_settings[:grid_visible] = !args.state.debug_settings[:grid_visible]
  end
end

def render_grid(args, size: 50)
  camera = args.state.camera
  center_x = camera.center[:x].idiv(size) * size
  center_y = camera.center[:y].idiv(size) * size

  offset = 0
  loop do
    render_horizontal_grid_line(args.outputs, camera, center_x + offset, center_y)
    render_horizontal_grid_line(args.outputs, camera, center_x - offset - size, center_y)
    render_vertical_grid_line(args.outputs, camera, center_x, center_y + offset)
    render_vertical_grid_line(args.outputs, camera, center_x, center_y - offset - size)
    offset += size
    break if offset > 1000
  end
end

def render_horizontal_grid_line(outputs, camera, x, y)
  start = camera.transform_object(x: x, y: y - 2000)
  finish = camera.transform_object(x: x, y: y + 2000)
  outputs.primitives << { x: start[:x], y: start[:y], x2: finish[:x], y2: finish[:y], r: 255, g: 0, b: 0 }.line!
end

def render_vertical_grid_line(outputs, camera, x, y)
  start = camera.transform_object(x: x - 2000, y: y)
  finish = camera.transform_object(x: x + 2000, y: y)
  outputs.primitives << { x: start[:x], y: start[:y], x2: finish[:x], y2: finish[:y], r: 0, g: 0, b: 255 }.line!
end

$state.objects = nil
