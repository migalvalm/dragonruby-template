def test_sound_play_picks_a_variant_and_pans args, assert
  audio = {}
  Sound.play audio, :hit, 1280, variants: %w[a.ogg b.ogg]
  assert.true! %w[a.ogg b.ogg].include?(audio[:hit][:input])
  assert.equal! audio[:hit][:x], 1.0
end

def test_sound_loop_restarts_only_when_the_path_changes args, assert
  audio = {}
  Sound.loop audio, :ambience, 'a.ogg', 1.0
  first = audio[:ambience]
  Sound.loop audio, :ambience, 'a.ogg', 1.0
  assert.true! audio[:ambience].equal?(first)
  Sound.loop audio, :ambience, 'b.ogg', 1.0
  assert.equal! audio[:ambience][:input], 'b.ogg'
end
