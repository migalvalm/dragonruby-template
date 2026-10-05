# Boot splash on black: the icon fading in and out, then the menu. Any key or click skips it.
class SplashScene
  attr_dr
  attr_reader :next_scene

  FADE  = 30    # ticks to fade in, and again to fade out
  TICKS = 120
  SIZE  = 256

  def self.alpha t
    255 * [t, TICKS - t, FADE].min.clamp(0, FADE) / FADE
  end

  def initialize
    @t = 0
  end

  def tick
    @t += 1
    outputs.background_color = [0, 0, 0]
    outputs.sprites << { x: 640, y: 360, w: SIZE, h: SIZE, anchor_x: 0.5, anchor_y: 0.5, path: 'metadata/icon.png', a: SplashScene.alpha(@t) }
    skip = inputs.keyboard.key_down.truthy_keys.any? || inputs.controller_one.key_down.truthy_keys.any? || inputs.mouse.click
    @next_scene = MenuScene.new if skip || @t >= TICKS
  end
end
