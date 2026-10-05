# CLAUDE.md

Always use the ponytail skill for coding tasks.
Always follow the DragonRuby Game Toolkit docs: local copy in the parent folder at `../docs/` (matches this SDK version, prefer it), online at https://docs.dragonruby.org/#/
Before writing code that uses an engine API, check its source in `../docs/oss/dragon/` (the engine's own Ruby, reference only — never edit; e.g. `geometry.rb`, `easing.rb`, `inputs.rb`/`keyboard.rb`/`mouse.rb`/`controller.rb`, `outputs.rb`, `attr_sprite.rb`, `layout.rb`, `numeric.rb`, `math.rb`). The `*_docs.rb` files hold the API docs.
Edit files directly in this checkout. Never create git worktrees unless explicitly asked to.
License: DragonRuby **Standard**. No C extensions, shaders or other Indie/Pro-only features. Video has no engine API: export it as PNG frames (ffmpeg) + a separate sound.

## Architecture (from ../docs/api/state.md, runtime.md, misc/philosophy.md)
- Grow incrementally; don't scaffold folders/classes ahead of need (DragonRuby philosophy rejects "Pit of Success" over-architecture).
- Entry point stays in `module Main` (`app/main.rb`). `args.state = {}` in `boot`. `$game ||= Game.new` owns the current scene; `reset` sets `$game = nil` since `DR.reset` doesn't clear class instances.
- Scenes are classes with `attr_dr` under `app/scenes/`. Contract: `tick` and `attr_reader :next_scene` (nil = stay); `Game#tick` switches at the end of the tick. Game scenes also have `attr_accessor :paused` (Esc opens `Game#pause_menu`) and split `tick` into `update` (skipped while paused) and `draw`.
- Keep game rules (inventory, combat, pricing) in plain classes with no `args`, so they're testable.
- **No coupling between scenes.** A scene never calls another scene's methods or reads its constants. Shared drawing helpers/layout go in their own module (`app/ui/`), each scene calls that. Grow folders as needed: `app/entities/` (things in the world), `app/world/` (level art/data), `app/ui/` (overlays, widgets); app-wide singles (`game.rb`, `sound.rb`, `settings.rb`, `controls.rb`) stay in `app/`.
- All menu/game input goes through `Controls.down` (`app/controls.rb`, keyboard + pad as one); movement stays `inputs.left_right` / `up_down`.
- Content is data: `data/*.json` loaded with `JsonFile.load` (keys symbolized). Read hashes with `[:key]`, not `.key` (`Hash#key` is a real method).
- Player options (`Settings`: volume, window scale, fullscreen) persist to `settings.txt`; the settings screen is `SettingsMenu`, shared by the menu and the pause menu.
- Debug-only drawing goes to `outputs.debug` (stripped in production).
- Area notes go in `.claude/rules/<area>.md` once an area grows (frame layouts, crops, tuning), next to the code that uses them.

## Collision (from ../docs/api/geometry.md, array.md; oss/dragon/geometry.rb)
- There is **no physics engine and no collision resolution**. The engine only answers "do these overlap?"; moving, testing and pushing back is our code. The usual DR loop: move → test → snap back to the edge you hit (or undo the move), one axis at a time.
- Everything is **axis-aligned rects** (AABB). Rotation (`angle`) is ignored by the rect tests. A rect = a Hash with `x, y, w, h` (or an object responding to them; objects also need `anchor_x`/`anchor_y` for `Geometry.rect?`). `anchor_x/anchor_y` **are** honoured, so `{ x: centre, anchor_x: 0.5 }` works.
- `a.intersect_rect?(b, tolerance = 0.1)` (mixed into Hash/Array/Entity; also `Geometry.intersect_rect?`). It's native C, not in `geometry.rb`. Overlap must exceed the tolerance, so **rects that only touch edges don't count**: snapping a box exactly to the other's edge is stable, no jitter.
- `inside_rect?` = fully contained. Collections: `Geometry.find_intersect_rect(rect, rects)` (first hit or nil), `find_all_intersect_rect`, `each_intersect_rect(a, b) { |x, y| }`, `find_collisions`, `Array#any_intersect_rect?`. All take `using: :hitbox` (a method/key or lambda) to test a hitbox instead of the object itself. They're faster than `rects.find { intersect_rect? }`. Quad trees (`Geometry.quad_tree_create` + `find_intersect_rect_quad_tree`) only when that's too slow, and only for static rects.
- Other shapes: `intersect_circle?`, `point_inside_circle?`, `circle_intersect_line?`, `line_intersect`, `ray_test`, `point_on_line?`, `intersect_bounding_box?` (any shape → its bounding rect).
- `inputs.mouse.intersect_rect?(rect)` / `mouse.inside_rect?` for clicks.

## Sound (from ../docs/api/audio.md; oss/dragon/args.rb `AudioHash`, runtime.rb)
- **One API**: `audio[key] = { input: path, gain: 1.0, pitch: 1.0, looping: false, paused: false, x: 0.0 }` (`audio` is available through `attr_dr`). `gain`/`pitch`/`x` **must be floats**. `x` is the pan, −1.0 (left) … 1.0 (right), relative to the listener. Extra keys (metadata) are allowed. The engine adds `playtime`/`playlength` once loaded. `outputs.sounds << path` is only a one-shot shortcut with a random key (no pitch/pan/control), so skip it.
- Non-looping entries **remove themselves** when they finish; looping ones stay until `audio.delete key` (or `= nil`). Assigning a new hash to a key that's playing **replaces** it (restarts), which is our voice limit: one key = one voice. `audio.volume` (0.0–1.0) is the master volume. `DR.reset` clears all audio.
- A Hash that was queued **can't be queued again** (it gets a `:cptr`, the engine logs a warning and ignores it). Always build a fresh hash per play, never keep one in a constant.
- **Formats (tested in this engine build)**: `.ogg`, `.wav`, `.mp3` load. WAV **must be 44.1 kHz**: 48 kHz Float32 logs `Invalid sample rate` but plays, 48 kHz **24-bit is dropped** (never plays). The docs recommend converting everything to `.ogg` (size, web builds), and `dragonruby-publish` warns on bad encodings and on capitals/spaces in file names. Converting: the `convert-audio` skill.
- **Pause**: sounds keep playing (the pause menu doesn't touch `audio`). To freeze them, set `paused: true` on the entries and back; ambience/music can keep going.
- `Sound.play audio, :name` picks a random variant from `data/sounds.json`; `Sound.loop` for beds/music.

## Code style (RuboCop, `.rubocop.yml`)
Run `rubocop` (from `mygame/`) before calling code done: it must report **no offenses**. Write code that passes it the first time:
- **Method size**: AbcSize ≤ 40, cyclomatic ≤ 12, perceived ≤ 13, ≤ 25 lines, ≤ 8 positional params (keyword args don't count). A method doing two jobs gets split into named steps, each with a one-line comment on what it is. Scenes follow the same shape: `update` = input → rules → interactions; `draw` = world → lighting → UI.
- **Don't repeat a sequence or a formula**: if two scenes run the same steps, or two methods compute the same thing, it goes in one method they both call.
- **No nested ternaries**. Use a lookup (`%i[bottom wall top][r]`, a `{ device => path }` hash), a direction as `(keys.right ? 1 : 0) - (keys.left ? 1 : 0)`, `dx.nonzero? || fallback`, or a multi-line `if`/`elsif`. Anything built per tile or per frame uses a constant table, not a fresh hash per call.
- **One statement per line**: no `;`, and an `else` branch's body on its own line (`elsif x then y` on one line is fine).
- `x.nil?` over `!!x`; `x&.foo` over `x && x.foo` (but plain `.` when nil answers it too: `prop.equal?(other)`); `transform_values` when only a hash's values change; parenthesise range ends with maths: `(first..(first + n))`.
- Comments go **above** a `def`, never on its line. Lines ≤ 160 chars (wrap long comments).
- Test helpers (setup shared by tests) are plain methods without the `test_` prefix, with a comment on the state they build.
- The config's exceptions are deliberate (mruby limits or house style, each with its reason in `.rubocop.yml`). Don't add a disable or raise a limit to silence a warning in new code; split the code instead.
- `rubocop -a` (safe fixes) is fine but check what it rewrote against the **mruby gotchas** below; never run `rubocop -A`.

## mruby gotchas (DragonRuby's Ruby; these break silently or fail to load)
- `Integer#/` returns a **Float** (`7 / 3 = 2.33`), which breaks built paths like `1_#{i}.png` (missing-texture checkerboard). Use `.div` for integer maths.
- `Array#rindex` takes no block ("wrong number of arguments"): search indexes with `(0...a.size).select { }.last`.
- `Hash#to_h` silently ignores a block, so keep `map { }.to_h` (RuboCop's `Style/MapToHash` is off for this); `transform_values` works when only the values change.
- `it` can't be a block parameter name ("formal argument cannot be it", the file fails to load). Neither can an underscore name like `|_t|` (same error); drop an unused parameter instead.
- `Kernel#rand` takes no Range (`rand(1..5)` raises "can't convert Range to Integer"): write `1 + rand(5)` (or `Numeric.rand(range)`); RuboCop's `Style/RandomWithOffset` is off for this.
- `Range#step` is missing ("step method missing on Range"): map over indexes instead, `(0..n.div(3)).map { |k| k * 3 }`.
- No Regexp. `rubocop -a` rewrites to `rand(1..5)` and `|_t|`, so check its output against this list.

## Running
- From the SDK folder (the one with `./dragonruby`, this folder unzipped into it as `mygame/`): `./dragonruby mygame`; tests: `./dragonruby mygame --test tests/<file>.rb`.
- Sample apps referenced in the docs (`./samples/...`) are NOT in this checkout; use https://samples.dragonruby.org.
- Lint: `rubocop` from `mygame/` (see **Code style**).
- Scene code (`tick`/`update`/`draw`) has no tests; smoke-test it with the `probe-scene` skill.
- Tests run with `Kernel.tick_count == -1`, so `frame_index` animations return nil there. Test the plain classes, not scene drawing.

## Assets
- Pixel art: keep `scale_quality=3` (SDL3 pixel-art shader) in `metadata/game_metadata.txt`; `1`/`2` blur sprites. Metadata is read at startup, so restart the game after changing it.
- All sprite files/folders are lowercase with `_` for spaces (DragonRuby warns otherwise); keep new assets that way.
- Asset notes (frame layouts, crops, sizes) live in `.claude/rules/` next to the code that uses them.
