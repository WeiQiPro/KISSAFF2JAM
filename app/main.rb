require "app/camera.rb"
require "app/renderer.rb"
require "app/sprite_stack.rb"
require "app/object_handler.rb"
require "app/input_handler.rb"
require "app/world.rb"

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
    $world ||= World.new(args)
    $world.args = args
    $world.update(args.inputs.keyboard)

    args.outputs.sprites << Renderer::_sprites($world.objects)
    args.outputs.sprites << {x: $world.camera.position.x, y: $world.camera.position.y, w: 10, h: 10, path: :pixel, r: 0, g: 0, b: 0 }
    debugger(args)
end