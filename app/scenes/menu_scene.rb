class MenuScene
  attr_dr
  attr_reader :next_scene

  # Buttons stacked centred from the top. dev: hidden in release builds.
  BUTTONS = [{ text: 'Play', action: :play }, { text: 'Settings', action: :settings },
             { text: 'Quit', action: :quit }].freeze

  def initialize title = 'New Game'
    @title = title
    list = BUTTONS.reject { |b| b[:dev] && GTK.production? }
    top = 330 + 40 * (list.size - 1)
    @buttons = list.each_with_index.map { |b, i| { x: 540, y: top - 80 * i, w: 200, h: 60 }.merge(b) }
  end

  def tick
    outputs.background_color = [20, 20, 30]
    keys = Controls.down(inputs)
    return @settings = !SettingsMenu.tick(outputs, inputs.mouse, keys) if @settings

    outputs.labels << { font: FONT, x: 640, y: 600, text: @title, size_px: 48, anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255 }
    button = Buttons.draw(outputs, inputs.mouse, @buttons, keys)
    choose button if button
  end

  # What a menu button does.
  def choose button
    case button[:action]
    when :play then @next_scene = PlayScene.new
    when :settings then @settings = true
    when :quit then gtk.request_quit
    end
  end
end
