# Constants for the window size
$WIDTH = 1280
$HEIGHT = 720

# Camera class to hold camera properties
class Camera
  attr_accessor :x, :y, :z, :fov, :zfar, :znear, :angle, :y_offset, :x_offset

  def initialize(x:, y:, z:, fov:, zfar:, znear:, angle:, y_offset:, x_offset:)
    @x = x
    @y = y
    @z = z
    @fov = fov
    @zfar = zfar
    @znear = znear
    @angle = angle
    @y_offset = y_offset
    @x_offset = x_offset
  end
end

class Sprite
  attr_accessor :x, :y, :z, :a, :stack, :w, :h, :source

  def initialize(x:, y:, z:, a:, stack:, w:, h:, source:)
    @x = x
    @y = y
    @z = z
    @a = a
    @stack = stack
    @w = w
    @h = h
    @source = source
  end
end

# Function to handle user controls
def controls(inputs, camera)
  move_amount = 5

  camera.y += move_amount if inputs.key_held.w
  camera.y -= move_amount if inputs.key_held.s

  camera.x += move_amount if inputs.key_held.d
  camera.x -= move_amount if inputs.key_held.a

  camera.angle -= inputs.key_held.right_arrow ? 5 : 0
  camera.angle += inputs.key_held.left_arrow ? 5 : 0

  camera.angle %= 360

end

# Function to convert 3D world coordinates to screen coordinates
def world_to_screen(x, y, z, camera)
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


# Function to render a sprite stack
def render_sprite_stack(sprite, camera)
  stack = []
  wts = world_to_screen(sprite.x, sprite.y, sprite.z, camera)

  if wts && wts[:scale] > 0
    sprite.stack.times do |index|
      stack << {
        x: wts[:x],
        y: wts[:y] + index * 2,
        w: sprite.w * wts[:scale],
        h: sprite.h * wts[:scale],
        path: sprite.source,
        source_x: 0,
        source_y: sprite.h * index,
        source_w: sprite.w,
        source_h: sprite.h,
        angle: wts.angle,
      }
    end
  end

  stack
end


def WorldUpdate(objects, camera, inputs)
  objects.each do |object|
    # Translate object to camera position
    object.x -= camera.x_offset + camera.x
    object.y -= camera.y_offset + camera.y

    # Rotate object around the player character's position
    if inputs.key_down.right_arrow
      object.x, object.y = rotate_point(object.x, object.y, 0, 0, -5)
    elsif inputs.key_down.left_arrow
      object.x, object.y = rotate_point(object.x, object.y, 0, 0, 5)
    end

    # Translate object back to original position
    object.x += camera.x_offset + camera.x
    object.y += camera.y_offset + camera.y
  end
end



def rotate_point(x, y, cx, cy, angle)
  radians = angle * Math::PI / 180
  new_x = Math.cos(radians) * (x - cx) - Math.sin(radians) * (y - cy) + cx
  new_y = Math.sin(radians) * (x - cx) + Math.cos(radians) * (y - cy) + cy
  [new_x, new_y]
end


def populate_world(num_objects)
  objects = []

  num_objects.times do
    # Generate random coordinates within a circle of radius 2000 around the origin
    radius = rand(2000)
    angle = rand(360)
    x = radius * Math.cos(angle * Math::PI / 180)
    y = radius * Math.sin(angle * Math::PI / 180)

    # Create a house-like object
    object = Sprite.new(x: x, y: y, z: 100, a: 45, stack: 49, w: 96, h: 58, source: "sprites/house_stack.png")
    objects << object
  end

  objects
end

# Create initial camera
$CAMERA = Camera.new(x: 0, y: 0, z: 50, fov: 90, zfar: 1000, znear: 10, angle: 0, y_offset: $HEIGHT / 2, x_offset: $WIDTH / 2)


def tick(args)
  if args.tick_count == 0
    args.state.objects = populate_world(100) # Populate the world with 100 objects
  end

  controls(args.inputs.keyboard, $CAMERA)

  # Update the world with the populated objects
  WorldUpdate(args.state.objects, $CAMERA, args.inputs.keyboard)

  args.state.objects.each do |sprite|
    args.outputs.sprites << render_sprite_stack(sprite, $CAMERA)
  end

  args.outputs.debug << "CAM X: #{$CAMERA.x}"
  args.outputs.debug << "CAM Y: #{$CAMERA.y}"
  args.outputs.debug << "CAM Angle: #{$CAMERA.angle}"
end

