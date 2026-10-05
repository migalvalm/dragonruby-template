# Player options: master volume, window size, fullscreen. Saved to settings.txt as "volume,scale,fullscreen".
# Game#tick applies the volume every tick (audio.volume), cycle applies the window when it changes.
module Settings
  VOLUMES = [1.0, 0.75, 0.5, 0.25, 0.0].freeze   # the first of each list is the default
  SCALES  = [1.0, 1.5, 2.0, 0.75].freeze         # × 1280x720
  FILE    = 'settings.txt'.freeze

  class << self
    attr_reader :volume, :scale, :fullscreen
  end

  # Reads the saved options (missing file or unknown values = the defaults). Once, at boot.
  def self.restore text = GTK.read_file(FILE)
    v, s, f = text.to_s.split(',')
    @volume = VOLUMES.find { |x| x.to_s == v } || VOLUMES[0]   # to_f would read a missing value as 0.0 = muted
    @scale = SCALES.find { |x| x.to_s == s } || SCALES[0]
    @fullscreen = f == 'true'
    apply_window unless text.nil?
  end

  # Steps an option (:volume, :scale, :fullscreen) to its next value, wrapping, then saves and applies it.
  def self.cycle option
    case option
    when :volume then @volume = after(VOLUMES, @volume)
    when :scale then @scale = after(SCALES, @scale)
    when :fullscreen then @fullscreen = !@fullscreen
    end
    GTK.write_file FILE, "#{@volume},#{@scale},#{@fullscreen}"
    apply_window
  end

  def self.after list, value
    list[(list.index(value).to_i + 1) % list.size]
  end

  # ponytail: set_window_scale is documented as desktop/dev only; on web/mobile only fullscreen means anything.
  def self.apply_window
    GTK.set_window_fullscreen @fullscreen
    GTK.set_window_scale @scale unless @fullscreen
  end

  # What each option's button shows next to it.
  def self.text option
    case option
    when :volume then "#{(@volume * 100).round}%"
    when :scale then "#{(1280 * @scale).round}x#{(720 * @scale).round}"
    else
      @fullscreen ? 'On' : 'Off'
    end
  end
end
