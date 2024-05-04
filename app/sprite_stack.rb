class SpriteStack
    attr_accessor :x, :y, :z, :a, :stack, :w, :h, :source, :r, :g, :b
  
    def initialize(x:, y:, z:, a:, stack:, w:, h:, source:, r:, g:, b:)
      @x = x
      @y = y
      @z = z
      @a = a
      @stack = stack
      @w = w
      @h = h
      @source = source
      @r = r
      @g = g
      @b = b
    end
  end