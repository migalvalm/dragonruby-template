FONT = 'fonts/monogram.ttf'

require 'app/json_file.rb'
require 'app/sound.rb'
require 'app/settings.rb'
require 'app/controls.rb'
require 'app/ui/dim.rb'
require 'app/ui/buttons.rb'
require 'app/ui/text_box.rb'
require 'app/ui/settings_menu.rb'
require 'app/scenes/splash_scene.rb'
require 'app/scenes/menu_scene.rb'
require 'app/scenes/play_scene.rb'
require 'app/game.rb'

module Main
  def boot args
    args.state = {}
    Settings.restore
  end

  def tick args
    $game ||= Game.new
    $game.args = args
    $game.tick
  end

  def reset _args
    $game = nil
  end
end
