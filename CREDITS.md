# Credits

Tiny Tailwind is an original game. The world, the enemies, the boss and every other picture are drawn in code for this game. The ship is an original 3D model made for this game. The names and maps are our own.

## The ship (v0.3.2)

- The Manta, an original design for this game. Google Gemini drew four top-down concepts (`art_source/ship_concepts_gemini.jpg`) and the final top-down drawing (`art_source/manta_topdown_gemini.jpg`). Meshy (meshy.ai, Meshy 7.1, BC's paid plan, licence set to Private) turned the drawing into the 3D model `art_source/manta.glb`.
  Changes: rendered into five top-down sprites with an outline by `tools/render_ship_sprites.py`. Sprites: `art/ship/`.
- v0.3.1 used the Swallow glider, an earlier original model made the same way. It was replaced in v0.3.2.

## Music (found through the Patch.gg asset library)

- "Stage 1" by Juhani Junkala. https://opengameart.org/content/4-chiptunes-adventure
  Licensed CC0 1.0 Universal. https://creativecommons.org/publicdomain/zero/1.0/
  Changes: re-encoded to Ogg Vorbis at 112 kbps. Used in the Sunmeadow.
- "Stage 2" by Juhani Junkala. https://opengameart.org/content/4-chiptunes-adventure
  Licensed CC0 1.0 Universal. https://creativecommons.org/publicdomain/zero/1.0/
  Changes: re-encoded to Ogg Vorbis at 112 kbps. Used in Echo Hollow and Thornkeep.
- "Epic boss battle" by Juhani Junkala. https://opengameart.org/content/boss-battle-music
  Licensed CC0 1.0 Universal. https://creativecommons.org/publicdomain/zero/1.0/
  Changes: re-encoded to Ogg Vorbis at 112 kbps. Used in the boss fight.

## Made for this game

- All sounds, made by `tools/make_sfx.py`.
- All art except the ship, drawn in code.
- The icon, drawn in code.

## Tools

- Godot Engine 4.6. https://godotengine.org (MIT licence)
