# Tiny Tailwind: handoff

Written by hand for v0.3.4 on 2026-11-15 (G2.5, until kit 1.6.0 writes it).

## Where the game stands

- v0.3.4 is out: https://bclark10121-cloud.github.io/tiny-tailwind/
- Godot 4.6.1, 2D, Android and browser. One biome: the Sunmeadow, Echo Hollow and Thornkeep.
- Source is still in this public repo. It moves to `games/tiny-tailwind/` in the private repo `game-studio` in the standards catch-up release.
- Shared kit 1.5.0. The newest kit is 1.8.0.

## What shipped last

- v0.3.4, quality of life: edge markers (`hud.gd` `_draw_markers`, goal from `main.gd` `goal_target()`), a Camera setting, fast travel from the Map page (`travel_to()`), find hints with per-area counts, a left-handed touch layout, fixed sticks and color-safe shots. Each is a setting with a safe save default.
- v0.3.3: the camera zooms in 1.4x (eases back to 1.0 in the boss arena), regular enemies never fire from off screen, and the engine flame and trail are much smaller. Use `view_size()` and `on_screen()` in `main.gd` for anything that needs the visible world area.
- v0.3.2: the Manta replaces the Swallow glider of v0.3.1. Five sprites rendered from a Meshy 3D model, 60 px across. Gameplay did not change.
- How it was made: four top-down concepts from Gemini (`art_source/ship_concepts_gemini.jpg`), each tested at game size on grass and stone. Brian picked the Manta. Gemini drew it clean from above (`art_source/manta_topdown_gemini.jpg`). Meshy built the model from that one image (`art_source/manta.glb`). Brian picked the 3D render over a flat version in a side by side game build.
- Re-render: `python3 -I tools/render_ship_sprites.py art_source/manta.glb <out> --nose +y --up +z` (needs `pip install trimesh moderngl pillow numpy scipy`). Copy the five PNGs into `art/ship/`. Keep mipmaps on in their `.import` files.
- Lesson: design new art from straight above first and test it at game size before modeling. Front and side views made the Swallow read as an airplane from above.
- The ship spec sheet is a Claude doc Brian owns: "Tiny Tailwind Ship Spec".

## What is next

1. Brian plays v0.3.4 and reports how the new options feel.
2. The standards catch-up release (Brian asked for standard Settings and 5 save slots, which come with it): source move, kit 1.8.0, icon master, debug menu, settings and save slots. See `instructions/UPDATE_2026-11-15_release_1.md` in `game-studio`.
3. Release 3, weapons (v0.4.0), unless Brian picks something else.
4. Backlog item 37: spec sheets for enemies, bosses, new ships and add-ons, each in the release that adds that art.

## Open bugs

- None known.

## Decisions waiting on Brian

- Confirm the four pillars in `CLAUDE.md` (G4.2).
- Whether enemies and bosses also become sprites from 3D models, or stay drawn in code. If yes, follow the Manta steps above.

## Build tools

Godot 4.6.1 with export templates, Android build-tools 35 and platform 35, Java 21. Set `export/android/android_sdk_path` and `export/android/java_sdk_path` in Godot's editor settings. Clone `game-studio` as `../game-standards` and `game-signing` as `../game-signing`.

## Start prompt for a new chat

> Continue Tiny Tailwind from the attached handoff zip. Read `CLAUDE.md`, `STANDARDS_OVERRIDES.md`, `BACKLOG.md` and this `HANDOFF.md` first. Clone `bclark10121-cloud/tiny-tailwind`, `game-studio` (as `../game-standards`) and `game-signing` (as `../game-signing`). Then ask me what to build next.
