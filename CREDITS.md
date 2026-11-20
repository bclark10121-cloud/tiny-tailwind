# Credits

Manta Quest: The Lost Pearl (Tiny Tailwind until v0.9.0) is an original game. The world and every other picture are drawn in code for this game. The ship and the seven foes are original 3D models made for this game. The names and maps are our own.

## The ship (v0.3.2)

- The Manta, an original design for this game. Google Gemini drew four top-down concepts (`art_source/ship_concepts_gemini.jpg`) and the final top-down drawing (`art_source/manta_topdown_gemini.jpg`). Meshy (meshy.ai, Meshy 7.1, BC's paid plan, licence set to Private) turned the drawing into the 3D model `art_source/manta.glb`.
  Changes: rendered into five top-down sprites with an outline by `tools/render_ship_sprites.py`. Sprites: `art/ship/`.
- v0.3.1 used the Swallow glider, an earlier original model made the same way. It was replaced in v0.3.2.

## The foes (v0.9.0)

- The lantern jellyfish, shrimp, lionfish spirit, spiral clam, pufferfish, ink squid and Thornhull the crab general are original designs for this game. Google Gemini drew the lineup and one close-up of each (`art_src/gemini/`). Meshy (meshy.ai, Meshy 7.1, BC's paid plan, licence set to Private) turned each close-up into a textured 3D model (`art_source/foes/`).
  Changes: rendered into one sprite each with a navy rim by `tools/render_foe_sprites.py`. The shrimp sprite is cut from its Gemini close-up. Sprites: `art/foes/`.

## Music (found through the Patch.gg asset library)

- Start screen title track (G5.21, v0.6.1): "Aquarium" by Kevin MacLeod (incompetech.com, https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1900026), licensed Creative Commons Attribution 4.0 International (https://creativecommons.org/licenses/by/4.0/). Changed by Patch: converted from MP3 to Ogg Vorbis, credit added to the Ogg comments. Changed: trimmed to a loop and level-matched. File `audio/music_title.ogg`.

- "Stage 1" by Juhani Junkala. https://opengameart.org/content/4-chiptunes-adventure
  Licensed CC0 1.0 Universal. https://creativecommons.org/publicdomain/zero/1.0/
  Changes: re-encoded to Ogg Vorbis at 112 kbps. Used in the Lantern Reef (was the Sunmeadow).
- "Stage 2" by Juhani Junkala. https://opengameart.org/content/4-chiptunes-adventure
  Licensed CC0 1.0 Universal. https://creativecommons.org/publicdomain/zero/1.0/
  Changes: re-encoded to Ogg Vorbis at 112 kbps. Used in Echo Grotto and the Sunken Palace.
- "Epic boss battle" by Juhani Junkala. https://opengameart.org/content/boss-battle-music
  Licensed CC0 1.0 Universal. https://creativecommons.org/publicdomain/zero/1.0/
  Changes: re-encoded to Ogg Vorbis at 112 kbps. Used in the boss fight.

## Made for this game

- All sounds, made by `tools/make_sfx.py`.
- All art except the ship, drawn in code.
- The app icon (v0.3.5): a large render of the Manta from `art_source/manta.glb`, on a sky, wind and meadow drawn by `tools/make_icon_master.py`.

## Tools

- Godot Engine 4.6. https://godotengine.org (MIT licence)

## Fonts (v0.3.8)

- Nunito Bold for menus and text. Copyright 2014 The Nunito Project Authors. SIL Open Font License 1.1 (`fonts/OFL-Nunito.txt`). From the Fontsource package `@fontsource/nunito` 5.3.0, Latin subset.
- Fredoka SemiBold for the title and world labels. Copyright 2016 The Fredoka Project Authors. SIL Open Font License 1.1 (`fonts/OFL-Fredoka.txt`). From the Fontsource package `@fontsource/fredoka` 5.3.0, Latin subset.
- Title font: Chewy, Apache License 2.0. Start screen, game page and Game Shelf card name (G5.21 Title, 2026-11-18). License text in `FONT-LICENSE-Chewy.txt`.
