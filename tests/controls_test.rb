def test_pad_buttons_press_the_keyboard_actions args, assert
  pad = args.inputs.controller_one.key_down
  pad.activate :start
  pad.activate :a
  keys = Controls.down args.inputs
  assert.true! keys.escape && keys.enter
  assert.false! keys.up
  pad.clear
end
