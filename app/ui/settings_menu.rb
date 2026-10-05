# The settings screen, over the main menu or the pause menu: each button steps its option, Back or Esc closes it.
module SettingsMenu
  BUTTONS = [{ x: 480, y: 360, w: 240, h: 60, text: 'Volume', option: :volume },
             { x: 480, y: 280, w: 240, h: 60, text: 'Window size', option: :scale },
             { x: 480, y: 200, w: 240, h: 60, text: 'Fullscreen', option: :fullscreen },
             { x: 480, y: 120, w: 240, h: 60, text: 'Back' }].freeze

  # Draws it (keys = Controls.down) and returns true when it closes.
  def self.tick outputs, mouse, keys
    outputs.sprites << Dim.screen(200)
    outputs.labels << { font: FONT, x: 640, y: 520, text: 'Settings', size_px: 48, anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255 }
    BUTTONS.each do |b|
      next unless b[:option]

      outputs.labels << { font: FONT, x: b.x + b.w + 24, y: b.y + b.h / 2, text: Settings.text(b[:option]), size_px: 30, anchor_y: 0.5, r: 255, g: 255, b: 255 }
    end
    button = Buttons.draw(outputs, mouse, BUTTONS, keys)
    Settings.cycle button[:option] if button && button[:option]
    keys[:escape] || (button && !button[:option])
  end
end
