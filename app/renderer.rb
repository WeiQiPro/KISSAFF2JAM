module Renderer
    def self._sprites(objects)
      stacks = []
      objects.each do |object|
        stacks << {
          x: object.x,
          y: object.y,
          w: object.w,
          h: object.h,
          path: :pixel,
          r: object.r,
          g: object.g,
          b: object.b,
          angle: 0
        }
      end
      
      stacks
    end

    def self._stacks(objects, camera)
        objects.each do |sprite|
            stack = []
            wts = World::world_to_screen(sprite.x, sprite.y, sprite.z, camera)
          
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
    end
end