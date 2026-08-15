# Cinematics

Build-ready clips live here, **inside `res://`**. Godot cannot load anything
from the repo root, so the masters in `/video/` are storage only — they are
invisible to the game.

**Format: Ogg Theora (`.ogv`). Godot 4 plays nothing else out of the box.**

```bash
ffmpeg -i ../../../video/master_cloud_shot.mp4 -c:v libtheora -q:v 8 -c:a libvorbis -q:a 5 spire_landing_01.ogv
```

Then assign the clips, in order, to `CinematicPlayer.clips` on the
`CinematicPlayer` node in `main.tscn`. They play back to back; two ten-second
clips make the twenty-second opener. Leave the list empty and the in-engine
grey-box landing plays instead.
