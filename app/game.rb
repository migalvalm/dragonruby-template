# Owns the current scene, switches scenes at the end of the tick, and runs the pause menu over game scenes.
# Scene contract: `tick`, `next_scene` (nil = stay). Game scenes also have `attr_accessor :paused` (Esc toggles it).
class Game
  attr_dr

  RESUME_BUTTON   = { x: 540, y: 360, w: 200, h: 60, text: 'Resume' }
  SETTINGS_BUTTON = { x: 540, y: 280, w: 200, h: 60, text: 'Settings' }
  MENU_BUTTON     = { x: 540, y: 200, w: 200, h: 60, text: 'Main menu' }

  def tick
    @scene ||= SplashScene.new
    @scene.args = args
    audio.volume = Settings.volume
    pausable = @scene.respond_to?(:paused=)             # game scenes; the menus aren't
    @scene.paused = !@scene.paused if pausable && !@settings && Controls.down(inputs)[:escape]
    @scene.tick
    next_scene = pausable && @scene.paused ? pause_menu : @scene.next_scene
    @scene = next_scene || @scene                       # switch scenes at the end of the tick
  end

  # Dims the frozen scene and returns the scene to switch to, if any.
  def pause_menu
    outputs.sprites << Dim.screen(170)
    if @settings
      @settings = !SettingsMenu.tick(outputs, inputs.mouse, Controls.down(inputs))
      return
    end

    outputs.labels << { font: FONT, x: 640, y: 520, text: 'Paused', size_px: 48, anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255 }
    case Buttons.draw(outputs, inputs.mouse, [RESUME_BUTTON, SETTINGS_BUTTON, MENU_BUTTON], Controls.down(inputs))
    when RESUME_BUTTON then @scene.paused = false   # false: Game#tick keeps the scene
    when SETTINGS_BUTTON
      @settings = true
      nil
    when MENU_BUTTON then MenuScene.new
    end
  end
end
