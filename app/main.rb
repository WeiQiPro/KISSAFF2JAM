$width = 1280
$height = 720

def controls(inputs)
  move_amount = 5
  offset_angle = 90

  $CAM.y_offset += 5 if inputs.key_held.w
  $CAM.y_offset -= 5 if inputs.key_held.s

  $CAM.x_offset += 5 if inputs.key_held.d
  $CAM.x_offset -= 5 if inputs.key_held.a

  $CAM.angle -= 5 if inputs.key_held.right_arrow
  $CAM.angle += 5 if inputs.key_held.left_arrow

  $CAM.angle %= 360
end

def world_to_screen x, y, z, a
  # Calculate the distance from the camera
  distance = z - $CAM.z

  # Calculate the scale based on the distance and field of view
  scale = $CAM.zfar / ($CAM.zfar - $CAM.znear) * $CAM.fov / (distance + $CAM.znear)

  # Calculate the screen x-coordinate based on the angle and distance
  rel_x = x - $CAM.x + $CAM.x_offset
  rel_y = y - $CAM.y + $CAM.y_offset
  screen_x = rel_x * Math.cos($CAM.angle * Math::PI / 180) - rel_y * Math.sin($CAM.angle * Math::PI / 180) + $width / 2

  # Calculate the screen y-coordinate based on the angle and distance
  screen_y = rel_x * Math.sin($CAM.angle * Math::PI / 180) + rel_y * Math.cos($CAM.angle * Math::PI / 180) + $height / 2

  # Calculate the angle difference between the camera's angle and the sprite's initial angle
  angle_diff = $CAM.angle - a

  # Normalize the angle difference to be between -180 and 180 degrees
  angle_diff = (angle_diff + 180) % 360 - 180

  # Calculate the sprite's new angle based on the camera's angle and the angle difference
  angle = a + angle_diff
  # Return the screen coordinates and scale
  return {
    x: screen_x + $CAM.x_offset,
    y: screen_y + $CAM.y_offset,
    scale: scale,
    angle: angle
  }
end

def draw_sprite_stack sprite
  stack = []
  wts = world_to_screen(sprite.x, sprite.y, sprite.z, sprite.a)

  #don't draw if scale is less than 0
  if wts && wts[:scale] > 0 

    #stack sprites vertically by index * 2
    #needs to be adjusted and offset by individual sprites
    sprite.stack.times do |index|
      stack << {
        x: wts[:x],
        y: wts[:y] + index * 2,
        w: sprite[:w] * wts[:scale],
        h: sprite[:h] * wts[:scale],
        path: sprite.source,
        source_x: 0,
        source_y: sprite[:h] * index,
        source_w: sprite[:w],
        source_h: sprite[:h],
        angle: wts.angle #should always face the direction it started
      }
    end
  end

  stack
end

def create_sprite(x, y, z, angle, stack, slw, slh, path, name)
  sprite = {
              x: x,
              y: y,
              z: z,
              a: angle, #starting angle or facing direction
              stack: stack, #total slices
              direction: :vertical, # based on how the sprite sheet is made vertical or horizontals / not implemented
              w: 96, #slice width
              h: 58, #slice height
              source: "sprites/house_stack.png", # sprite path
              path: :house_stack #for render_targets / not implemented
  }

  sprite
end


$CAM = {
  x: 0,
  y: 0,
  z: 60,
  fov: 90,
  zfar: 100,
  znear: 10,
  zfarnear: 1 /(100 - 10),
  pitch: -45, #top down view
  angle: 0,
  y_offset: 0,
  x_offset: 0
}

$house = create_sprite(0, 0, 100, 45, 49, 96, 58, "/sprites/house_stack.png", :house_stack)
$house2 = create_sprite(200, 200, 100, 90, 49, 96, 58, "/sprites/house_stack.png", :house_stack)



def tick args

  controls(args.inputs.keyboard);

  args.outputs.sprites << {x: $CAM.x_offset, y: $CAM.y_offset , w: 10, h: 10, path: :pixel, r: 125, g: 125, b: 125 }
  args.outputs.sprites << draw_sprite_stack($house)
  args.outputs.sprites << draw_sprite_stack($house2)
  args.outputs.debug << "CAM Angle: #{$CAM.angle}"
end