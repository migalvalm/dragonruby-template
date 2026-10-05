---
name: probe-scene
description: Smoke-test scene code (tick/update/draw of PlayScene, MenuScene, etc.), which has no unit tests, with a throwaway probe test. Use after changing a scene to check it runs without errors.
---

# Probe a scene

Scene code has no tests. To check a change runs:

1. Write a throwaway `tests/zz_probe_test.rb` that:
   - stubs the clock, since `frame_index` is nil at the test default of -1:
     ```ruby
     module Kernel
       def self.tick_count = ($t = ($t || 100) + 1)
     end
     ```
   - builds the scene (e.g. `PlayScene.new`) and sets `scene.args = args`,
   - drives it into the changed path with `instance_variable_set`, or `send`s a step with a `Struct` standing in for the keys,
   - ticks it a few times (`scene.tick`) and asserts on the state you expect.
2. Run it from the SDK folder: `./dragonruby mygame --test tests/zz_probe_test.rb`.
3. **Delete the file afterwards**. It's never committed.
