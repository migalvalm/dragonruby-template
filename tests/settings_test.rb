def test_settings_restore_falls_back_to_defaults args, assert
  Settings.restore nil
  assert.equal! [Settings.volume, Settings.scale, Settings.fullscreen], [1.0, 1.0, false]
  Settings.restore 'loud,9,maybe'
  assert.equal! [Settings.volume, Settings.scale, Settings.fullscreen], [1.0, 1.0, false]
end

def test_settings_steps_wrap args, assert
  assert.equal! Settings.after(Settings::VOLUMES, 1.0), 0.75
  assert.equal! Settings.after(Settings::VOLUMES, 0.0), 1.0
  assert.equal! Settings.after(Settings::SCALES, 0.75), 1.0
end

def test_settings_restore_reads_saved_values args, assert
  Settings.restore '0.25,1.5,false'
  assert.equal! [Settings.volume, Settings.scale, Settings.text(:scale)], [0.25, 1.5, '1920x1080']
  Settings.restore nil
end
