# The game. Replace me. A box you move with arrows/WASD/stick, kept on screen.
class PlayScene
  attr_dr
  attr_accessor :paused
  attr_reader :next_scene

  SPEED = 6

  def initialize
    @player = { x: 640, y: 360, w: 32, h: 32, anchor_x: 0.5, anchor_y: 0.5 }
  end

  def tick
    update unless @paused
    draw
  end

  # Input, then the rules.
  def update
    @player.x = (@player.x + inputs.left_right * SPEED).clamp(16, 1264)
    @player.y = (@player.y + inputs.up_down * SPEED).clamp(16, 704)
  end

  # The world, then the UI.
  def draw
    outputs.background_color = [30, 30, 40]
    outputs.sprites << @player.merge(path: :solid, r: 200, g: 60, b: 60)
    outputs.labels << { font: FONT, x: 20, y: 700, text: 'Esc: pause', size_px: 24, r: 200, g: 200, b: 200 }
  end
end
