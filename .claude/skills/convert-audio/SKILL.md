---
name: convert-audio
description: Convert or resample sound files so DragonRuby plays them (44.1 kHz WAV, or .ogg for shipping), and rename them to lowercase. Use when a sound won't play, logs "Invalid sample rate", or new audio is added.
---

# Convert audio

The engine drops 48 kHz 24-bit WAV (it never plays), and 48 kHz Float32 logs `Invalid sample rate`. WAV must be 44.1 kHz. `.ogg` is preferred for shipping (size, web builds).

Sources live in `sounds/originals/<folder>/` (kept out of builds by `ignore_directories=originals`; `sounds/` is gitignored, so never delete them). The game only ships the `.ogg` next to them in `sounds/<folder>/`.

1. **Inspect**: `afinfo <file>` (macOS) gives the sample rate and bit depth (it can't read `.ogg`: use `ffprobe`).
2. **Convert**:
   - To ogg (preferred): `ffmpeg -nostdin -loglevel error -i sounds/originals/music/In_File.wav -ac 2 -ar 44100 -c:a pcm_s16le -f wav - | oggenc -Q -q 5 -o sounds/music/in_file.ogg -` (Homebrew's ffmpeg has no `libvorbis`, and its built-in `vorbis` encoder is experimental; `oggenc` is from `brew install vorbis-tools`)
   - WAV only, 16-bit: `ffmpeg -i in.wav -ar 44100 -c:a pcm_s16le out.wav`
   - ffmpeg may be missing (`brew install ffmpeg`); the stopgap is `afconvert -f WAVE -d LEI16@44100 in.wav out.wav`.
3. **Name**: lowercase with `_` (`dragonruby-publish` warns on capitals and spaces).
4. **Wire**: add the new path to `data/sounds.json`.
5. **Verify**: `./dragonruby mygame --test tests/sound_test.rb`, then play it in-game and watch the console for warnings.
