# Tiny Tailwind: project rules

Tiny Tailwind is Brian's twin-stick adventure shooter: a small ship explores a meadow, a cave and a keep. Godot 4.6, 2D, Android and browser. This repo is public.

## Standards (G0.10, G10)

- Read `GAME_STANDARDS.md` (rule ids start with G) and `ENGINEERING_STANDARDS.md` (rule ids start with E) first. Both live only in the private repo `bclark10121-cloud/game-standards`. Clone it to `../game-standards`, outside this repo. This repo holds no copies.
- Overrides, open items and the standards version this game was checked against live in `STANDARDS_OVERRIDES.md`. Order of authority: Brian in the chat, then `STANDARDS_OVERRIDES.md`, then the standards.
- The shared kit is pulled into `addons/bc_common/`, `tools/common/` and `tests/common/` with `bash ../game-standards/common/sync_common.sh ../game-standards .`. `common.lock` names the version. Never edit those files here. Propose kit changes to Brian.
- Signing: the key and its settings live in the private repo `bclark10121-cloud/game-signing`, cloned to `../game-signing` (G1.7). Build with `tools/common/sign_android.sh`. Never commit a key or password, and never write a password in a build file or a reply (G1.9).

## Pillars (never break these)

Proposed 2026-11-15. Brian to confirm (G4.2).

1. Tight twin-stick feel. Move and aim are separate and instant.
2. Explore to grow. Every corner holds a find or an upgrade.
3. Kind difficulty. Checkpoints are close, defeat costs nothing and assists are always there.
4. Original everything. Our own names, world and art. Nothing from Minishoot' Adventures or any other game (G8.4).

This game has combat, enemies and bosses. Override rows 1 and 2 in `STANDARDS_OVERRIDES.md` (Brian, 2026-11-15).

## Decisions from Brian

- 2026-11-15: use best judgment for the MVP. One biome only (the meadow, with its cave and keep) until the gameplay is good.
- 2026-11-15: add the game to The Game Shelf with every update, in the same card format as the other games.
- 2026-11-15: the ship is a 3D model (Gemini, then Meshy) rendered into sprites for the 2D game. Shipped on its own as v0.3.1. Spec sheets for enemies, bosses, new ships and add-ons are backlog item 37.
- 2026-11-15: the Swallow glider did not look good in game. Brian picked the Manta from four top-down concepts tested at game size, and the Meshy render over the flat drawing. Shipped as v0.3.2 at 60 px across. Design new art from straight above first and test it at game size before modeling.
- 2026-11-15: a closer camera so everything is bigger, and less thrust from the back of the ship. Shipped as v0.3.3.

## Rules

- The world is a tile grid, 64 px a tile. `tools/make_world.py` writes `data/world.json`. Tiles: `#` wall, `.` floor, `~` water, `^` rift. Only a dash crosses a rift.
- Enemies live in `data/enemies.json`, finds in `data/finds.json`, breakables in `data/props.json` and shop items in `data/shop.json`. Coin caches, breakables and Wren's Wagon are placed in `tools/make_world.py`. New enemies, finds, rooms, caches and shop items need no new code (G4.9).
- Movement, shots and hits are plain maths in `scripts/main.gd`. No physics bodies (override 6).
- The camera zooms in 1.4x (`CAM_ZOOM`) and eases back to 1.0 in the boss arena (`CAM_ZOOM_BOSS`), which is taller than the close view. Anything that needs the visible world area uses `view_size()` and `on_screen()`, never the raw viewport size (v0.3.3).
- Regular enemies never fire from off screen (v0.3.3, pillar 3).
- Shots, sparks and pickups live in pools made once. Never create or free nodes during play (E4.5).
- All art is drawn in code in `scripts/world_view.gd` and `scripts/hud.gd`. No textures, with one exception: the ship. Its five sprites in `art/ship/` are rendered from the Meshy model `art_source/manta.glb` with `python3 -I tools/render_ship_sprites.py art_source/manta.glb <out> --nose +y --up +z` (Brian, 2026-11-15). Godot skips `art_source/`, so the model stays out of the builds. Any other texture needs Brian's OK. Use only letters, digits and plain punctuation in on-screen text: the built-in font has no star or box symbols.
- Save file is `user://tiny_tailwind.json`, format `v: 1`, written with `addons/bc_common/save_store.gd`. Only add fields, each with a safe default. Find ids, checkpoint ids and arena ids from a save are checked against the data files (E6.7).
- Never rename a find id, a checkpoint id, an arena id, a coin cache id or a shop item id. Shop purchases and caches from a save are checked against the data (E6.7).
- Breakables are solid and can be shot. They must never block the only way to anything: `--reach` checks it.
- Short sounds come from `tools/make_sfx.py` (mono 22.05 kHz `.wav`). Music comes from the Patch.gg library (G8.1). Every outside asset goes in `CREDITS.md`.
- Xbox button names everywhere a player reads them: A, B, RB, RT, View, Menu, D-pad. Never Back or Start (G5.8). `InputSetup.add_controller_ui()` runs at startup.
- No personal names on the game page, the card or public repo files beyond the first name (G1.11).

## Test gate

- `bash tools/common/sync_common.sh --check .` must print `COMMON check ok` (G10.3).
- `bash tools/common/check_secrets.sh` must print `SECRETS check ok` (G1.9).
- `godot --headless --path . -s res://tests/common/save_store_check.gd` must print `SAVESTORE check ok` (E6.7).
- `godot --headless --path . -- --reach` must print `REACH ok 20/20` and `REACH caches 10/10` (G7.2). It also proves the Dash Core is reachable on foot, the keep is gated by the dash, breakables block nothing and the shop is reachable on foot.
- `godot --headless --path . -- --bot` must print `BOT done` (override 5). The bot plays the whole route on Relaxed, collects every cache and buys at the shop. Add `--normal` for Normal.
- `python3 tests/web_test.py <web folder> <shots folder>` must print `errors []`. View the screenshots (G7.3).
- `python3 tests/pad_test.py <web folder> <shots folder>` must print `errors []`. It plays from the title card through every Menu page and the end card with only the kit's pretend Xbox controller (G5.8).
- Test hooks run only with the whole-word `?test` flag and never in the APK (G7.8). `?notch` adds a pretend notch, only together with `?test`.
- `python3 tests/common/page_check.py https://bclark10121-cloud.github.io/tiny-tailwind/` after every push must print `errors []`.

## Deliver every time (every release)

1. Game page link: https://bclark10121-cloud.github.io/tiny-tailwind/ (give Brian this link, not the direct play link)
2. GitHub repo link: https://github.com/bclark10121-cloud/tiny-tailwind
3. The APK, named `TinyTailwind-v<version>.apk`, in `docs/downloads/` and sent to Brian as a file. Package id `com.brianclark.tinytailwind`. Raise `version/code` by one on every build.
4. The backlog: `BACKLOG.md`, updated, linked and sent as a file.
5. The handoff zip, built with `tools/common/make_handoff.sh ../game-standards` and sent as a file.
6. `docs/index.html` updated: the line under the buttons reads exactly `Version <version>. Release notes · Backlog · Source on GitHub` (G1.8). `docs/release-notes/v<version>.md` added with a test checklist and the kit version (G10.4). The browser build goes in `docs/play/`.
7. The Game Shelf card refreshed in `bclark10121-cloud.github.io` in the same push, every update: replace `images/tiny-tailwind.jpg` with a fresh 960 x 540 screenshot and update the card text when it changed (G2.7). Keep the same card format as the other games. Change only this game's card. Give Brian the dashboard link: https://bclark10121-cloud.github.io/

## Reporting to Brian

Lead with the links and files. Segment the answer. Short active sentences. No em dashes, no semicolons, no Oxford comma. State plainly what was tested and where. List every judgment call.
