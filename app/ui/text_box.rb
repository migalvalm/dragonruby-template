# A one-line box the player types into (a room name now; later any name/code/note). Plain class, no args:
# the scene feeds it inputs.text (the characters typed this tick) and keyboard.key_down every tick, and draws it.
# Opening one starts DR text input (the on-screen keyboard on touch devices); Enter/Escape stop it.
class TextBox
  attr_reader :text

  W = 480
  H = 56

  # allowed = a String of the characters it accepts (nil = any); anything else typed is ignored.
  def initialize text = '', max = 24, allowed = nil
    @text, @max, @allowed = text, max, allowed
    DR.start_text_input
  end

  # Returns :done (Enter, not empty), :cancel (Escape) or nil while typing.
  def update chars, keys
    chars.join.each_char { |c| @text += c if @text.size < @max && (!@allowed || @allowed.include?(c)) }
    @text = @text[0...-1] if keys.backspace
    result = if (keys.enter || keys.kp_enter) && !@text.empty? then :done
             elsif keys.escape then :cancel
             end
    DR.stop_text_input if result
    result
  end

  # The prompt above, the box centred on x, y, and the text with a blinking caret.
  def draw outputs, x, y, prompt
    caret = Kernel.tick_count.div(30).even? ? '_' : ''
    outputs.sprites << { x: x, y: y, w: W, h: H, anchor_x: 0.5, anchor_y: 0.5, path: :solid, r: 200, g: 200, b: 200 }
    outputs.sprites << { x: x, y: y, w: W - 4, h: H - 4, anchor_x: 0.5, anchor_y: 0.5, path: :solid, r: 20, g: 20, b: 20 }
    outputs.labels << { font: FONT, x: x, y: y + H, text: prompt, anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255 }
    outputs.labels << { font: FONT, x: x - W / 2 + 16, y: y, text: @text + caret, size_px: 30, anchor_y: 0.5, r: 255, g: 255, b: 255 }
    outputs.labels << { font: FONT, x: x, y: y - H, text: 'Enter: ok   Esc: cancel', anchor_x: 0.5, anchor_y: 0.5, r: 160, g: 160, b: 160 }
  end
end
