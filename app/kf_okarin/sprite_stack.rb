module KfOkarin
  class SpriteStack
    MAX_RENDER_TARGET_H = 16_384

    def initialize(sprites)
      @sprites = sprites
      validate_sprites

      original_w = @sprites[0][:w]
      original_h = @sprites[0][:h]
      @sprite_size = Math.sqrt(original_w**2 + original_h**2).ceil # Take diagonal so any rotation fits
      @sprite_offset_x = (@sprite_size - original_w).idiv(2)
      @sprite_offset_y = (@sprite_size - original_h).idiv(2)
      @sprite_sheet_row_count = MAX_RENDER_TARGET_H.idiv(@sprite_size)
      @sprite_sheet_w = (@sprites.size / @sprite_sheet_row_count).ceil * @sprite_size
      @sprite_sheet_h = @sprite_size * [@sprites.size, @sprite_sheet_row_count].min
      @sprite_sheet_target_name = :"sprite_stack_#{object_id}_sprite_sheet"
      @last_rendered_perspective = nil
    end

    # For debugging purposes
    def sprite_sheet
      { path: @sprite_sheet_target_name, w: @sprite_sheet_w, h: @sprite_sheet_h }
    end

    def render(args, x:, y:, perspective:)
      rebuild_sprite_sheet(args, yaw: perspective.yaw) if @last_rendered_perspective&.yaw != perspective.yaw

      # TODO: Memoize final rendered sprite, too
      scale = perspective.scale
      rendered_w = @sprite_size * scale
      rendered_h = rendered_w * Math.sin(perspective.pitch.to_radians)
      rendered_x = x - rendered_w.idiv(2)
      rendered_y = y - rendered_h.idiv(2)
      pitch_cos = Math.cos(perspective.pitch.to_radians)

      @sprites.each_with_index { |sprite, z|
        perspective.scale.times { |scale_offset|
          args.outputs.primitives << {
            x: rendered_x, y: rendered_y + (z * pitch_cos * scale) + scale_offset, w: rendered_w, h: rendered_h,
            path: @sprite_sheet_target_name,
            source_x: z.idiv(@sprite_sheet_row_count) * @sprite_size,
            source_y: (z % @sprite_sheet_row_count) * @sprite_size,
            source_w: @sprite_size,
            source_h: @sprite_size,
          }.sprite!
        }
      }
      @last_rendered_perspective = perspective
    end

    private

    def validate_sprites
      w = @sprites[0][:w]
      h = @sprites[0][:h]
      sprites_all_have_same_dimensions = @sprites.all? { |sprite| sprite[:w] == w && sprite[:h] == h }
      raise 'Sprites must have the same width and height' unless sprites_all_have_same_dimensions
    end

    def rebuild_sprite_sheet(args, yaw:)
      render_target = args.outputs[@sprite_sheet_target_name]
      render_target.width = @sprite_sheet_w
      render_target.height = @sprite_sheet_h
      # for some reason it looks really ugly when exactly at a yaw of 90/-90 - so let's just ignore those
      yaw = 89 if yaw == 90
      yaw = -89 if yaw == -90

      @sprites.each_with_index do |sprite, z|
        cell_x = z.idiv(@sprite_sheet_row_count) * @sprite_size
        cell_y = (z % @sprite_sheet_row_count) * @sprite_size
        render_target.sprites << {
          x: cell_x + @sprite_offset_x,
          y: cell_y + @sprite_offset_y,
          angle: yaw,
          **sprite
        }
      end
    end
  end
end
