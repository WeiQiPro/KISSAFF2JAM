def build_sprite_stack_from(path:, w:, h:, sprite_count:)
  sprites = sprite_count.times.map { |z|
    {
      w: w, h: h, path: path,
      source_x: 0, source_y: z * h, source_w: w, source_h: h
    }
  }
  SpriteStack.new(sprites)
end
