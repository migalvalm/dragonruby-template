# Every sound goes through here. Scenes call it; entities only report what happened.
module Sound
  # name => variants, from data/sounds.json ({ "hit": ["sounds/hit_1.ogg", "sounds/hit_2.ogg"] });
  # play picks one at random so repeats stay fresh.
  SETS = JsonFile.load('data/sounds.json').freeze

  # One-shot: a random variant at a slightly random pitch, panned by where it is on screen.
  # The key is the name, so playing it again restarts it instead of stacking (one voice per name).
  # Pass pitch 1.0 when something is timed to the sound. variants: paths from elsewhere. key: its own voice instead.
  def self.play audio, name, screen_x = 640, gain = 1.0, pitch = 0.9 + rand * 0.2, variants: SETS[name], key: name
    audio[key] = { input: variants[rand(variants.size)], gain: gain, pitch: pitch,
                   x: ((screen_x - 640) / 640.0).clamp(-1.0, 1.0) }
  end

  # Looping bed on `key`. Call it every tick: it only (re)starts when the path changes, so scenes swap beds on entry.
  def self.loop audio, key, path, gain
    audio[key] = { input: path, gain: gain, looping: true } unless audio[key]&.input == path
  end
end
