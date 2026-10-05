# A black sheet over the whole screen at alpha a: menus and overlays dim the scene behind them with it.
module Dim
  def self.screen a
    { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 0, g: 0, b: 0, a: a }
  end
end
