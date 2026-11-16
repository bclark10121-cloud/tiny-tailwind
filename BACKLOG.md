# Tiny Tailwind: backlog

Updated 2026-11-16 for v0.3.6. BC decides the order.

## Done

- v0.1.0 (2026-11-15), the first beta. One biome: the Sunmeadow, its cave (Echo Hollow) and its keep (Thornkeep).
  - Twin-stick flying and shooting with touch, controller and keyboard and mouse.
  - 6 enemy kinds and 1 boss.
  - The Dash Core: a dash that crosses rifts and slips past shots.
  - Crystals, levels and 4 ship stats to upgrade.
  - 20 finds with a counter and a journal. 3 of them add a heart.
  - 8 checkpoints. Defeat costs nothing.
  - Assists: 3 difficulty levels, auto aim, game speed and invincible.
  - Map page, Menu row, title card, end card and a save on the device.

- v0.1.1 (2026-11-15). BC could not fly the ship with the controller in a browser on his ROG handheld. The D-pad now flies the ship. The title card and Settings name the controller the game sees. The game page has handheld steps. Cause found by BC: the handheld was in PC mode. Gamepad mode fixed it.
- v0.1.2 (2026-11-15). BC found movement very choppy. The map is now drawn once, so the game's own work per frame dropped from about 20 ms to under 2 ms in a slow test browser. The ship eases into moves, slides around wall corners and the camera eases. A Frame rate setting shows the frames a second.
- v0.2.0 (2026-11-15), the Feel release. BC found v0.1.2 much smoother and asked for bigger shots, then for best judgment on quality of life. Bigger shots, aim assist levels, a corner mini map, enemy health bars, a low health warning, auto pause, screen shake, rumble and touch stick settings.
- v0.2.1 (2026-11-15). BC asked for a different default ship shape and picked the Swallow glider from four options. The ship turns smoothly toward the aim. New app icon.
- v0.3.0 (2026-11-15), Release 2: coins and the shop. Coins from enemies, trees and breakable bushes, crystals and pots. 10 hidden coin caches. Wren's Wagon with 7 items: Repair kit, Heart seed, Spare part, Coin magnet, Shield charm, Quick dash and Treasure map.
- v0.3.1 (2026-11-15). BC asked for a 3D modeled ship. The Swallow glider got Gemini reference views, a Meshy 3D model and a spec sheet. The game now draws the ship from five sprites rendered from that model. It banks into turns and sideways moves. Gameplay did not change.
- v0.3.2 (2026-11-15). BC found the Swallow glider did not look good in game. A new ship, the Manta: Gemini drew four top-down concepts, each tested at game size on grass and stone. BC picked the Manta, and the Meshy 3D render over the flat drawing in a side by side game build. 60 px across, a wide rounded ray shape in sky blue and orange.
- v0.3.3 (2026-11-15). BC asked for a closer camera so everything is bigger, and less thrust from the back of the ship. The camera zooms in 1.4x and eases back out in the boss arena so the whole fight stays in view. Regular enemies no longer fire from off screen. The engine flame and the trail behind the ship are much smaller.
- v0.3.4 (2026-11-15), quality of life. BC took all the suggested QoL items. Edge markers for enemies off screen, Wren's Wagon and the next goal. A Camera setting (Close or Normal). Fast travel between reached checkpoints from the Map page. Find hints: a soft chime and a gold ring near a keepsake, plus keepsake and cache counts per area on the Map page. A left-handed touch layout and fixed sticks. Color-safe shot colors. Each one is a setting.
- v0.3.5 (2026-11-16), the standards catch-up with no new content (Release 4). Five save slots with Continue, Play and Delete. The kit Settings panel with Music and Sound in five levels, Text size and Reduce motion, and this game's twelve options. The Menu row Resume, Settings, How to play, Ship, Journal, Map, Title. How to play with every control and the device in use marked. Hints and the title card follow the device in use. Pause on app, tab and controller loss. Rumble buzzes the phone too. Tester tools behind a code in test builds. A new icon of the Manta. A privacy page. GitHub Releases. The source moved to the private `game-studio` repo. Version code 11.
- v0.3.6 (2026-11-16), sound fix (BC 2026-11-16: no music in the browser). The Music and Sfx buses come from `default_bus_layout.tres` instead of `AudioServer.add_bus()` at runtime, which left every sound silent in the browser build. New `tests/audio_test.py` measures the page's real sound output. Version code 12.

## Now

- BC tries v0.3.5 on a real phone and an Xbox controller.
- The graphics work staged in BC's other chat (`staging/graphics-phase1` and `staging/graphics-phase2` in the page repo, built on v0.3.4 with the source still there) moves onto the new source in `game-studio` next.
- Then Release 3, weapons (v0.4.0), unless BC picks something else.

## Asked for by BC, not built yet

Asked 2026-11-15. The release each one lands in is shown in the roadmap.

1. 10 biomes.
2. 300 collectibles.
3. Hidden rooms.
4. 10 boss battles.
5. New weapon types to find.
6. New weapon upgrades to find.
7. A shop with items to buy. Done in v0.3.0.
8. Coins to find around the biomes to buy things. Done in v0.3.0.
9. Shooting trees and enemies makes them drop coins the ship picks up. Done in v0.3.0.
10. New ships.
11. New ship add-ons.
12. New paint colors for ships.
37. Spec sheets for more art, like the Swallow glider ship spec: one for each enemy, boss, new ship and ship add-on. Each holds reference views, colors, size, markers and a hitbox. Asked 2026-11-15. Each sheet lands in the release that adds that art.

## Ideas to choose from (BC picks by number)

Suggested 2026-11-15. Each has a place in the roadmap. BC can move or drop any of them.

13. Corner mini map, with a toggle. Done in v0.2.0.
14. Fast travel between checkpoints. Done in v0.3.4.
15. Lost friends to rescue. Each one opens something in a home village: the shop, the hangar, the paint stall.
16. More gate abilities: a boost that skims water, a bomb that opens cracked walls and a shield.
17. Charged super shot on a second button.
18. Elite enemies and mini bosses.
19. Challenge rooms with a personal best time.
20. Boss rush, unlocked after the last boss.
21. Stamp card of achievements.
22. Three save slots. Replaced by the 5 save slots standard (G5.12), coming in the standards catch-up release.
23. Controller rumble and a screen shake setting. Done in v0.2.0.
24. Aim assist strength setting, between off and full auto aim. Done in v0.2.0.
25. Scenery that breaks: bushes, pots and crates. Done in v0.3.0 (bushes, pots and cave crystals).
26. Day and night, and weather per biome.
27. Music per biome and a theme per boss.
28. A short story intro and friends who talk.
29. Find hints: a soft ping when a find is near. Done in v0.3.4, with keepsake and cache counts per area on the Map page.
30. Touch settings: stick size, left-handed layout and a fixed stick option. Done (stick size in v0.2.0, left-handed and fixed sticks in v0.3.4).
31. Color-safe shot colors for color blind players. Done in v0.3.4.
32. Christmas theme toggle (G4.5).
33. A helper drone that shoots with you.
34. New Game Plus.
35. Photo mode.
36. Enemy journal: a page for each enemy you have beaten.
38. Edge markers for enemies off screen, the shop and the next goal. Done in v0.3.4.
39. Camera setting: Close or Normal. Done in v0.3.4.

## Roadmap: 10 releases

Order of thought: feel first, then the money loop, then things to collect and wear, then the world grows. Biome 2 waits until the gameplay is good (BC, 2026-11-15).

| Release | Theme | What is in it | Backlog items |
|---|---|---|---|
| 1. v0.2.0, done | Feel | Fixes from BC's playtest. Tuning of speed, shots and enemies. Better hit and hurt feedback. Aim assist strength, rumble, shake setting, touch settings, corner mini map. Still one biome | 13, 23, 24, 30 |
| 2. v0.3.0, done | Coins and the shop | Coins hidden around the biome. Trees, bushes and enemies drop coins when shot. A shop with items to buy. Scenery that breaks | 7, 8, 9, 25 |
| 3. v0.4.0 | Weapons | New weapon types to find, such as a spread shot, a piercing shot and a homing shot. Weapon upgrades to find. A charged super shot | 5, 6, 17 |
| 4. v0.5.0 | Secrets | Hidden rooms and cracked walls. Finds in the first biome rise to 30. Find hints. Enemy journal. Elite enemies | 3, 18, 29, 36, part of 2 |
| 5. v0.6.0 | The hangar | New ships with their own strengths. Ship add-ons. Paint colors. Three save slots | 10, 11, 12, 22 |
| 6. v0.7.0 | Biome 2 | The second biome with its cave, keep and boss. A new gate ability. Lost friends and the home village. Fast travel | 14, 15, 16, part of 1, 2 and 4 |
| 7. v0.8.0 | Biomes 3 and 4 | Two more biomes and bosses. Music per biome. Day, night and weather | 26, 27, part of 1, 2 and 4 |
| 8. v0.9.0 | Biomes 5 to 7 | Three more biomes and bosses. Mini bosses. Challenge rooms. Stamp card | 19, 21, part of 1, 2 and 4 |
| 9. v0.10.0 | Biomes 8 to 10 | The last three biomes and bosses. 10 biomes, 10 bosses and 300 collectibles complete. An ending | 1, 2, 4 complete, 28 |
| 10. v1.0.0 | Finish | Boss rush, New Game Plus, helper drone, color-safe shots, Christmas theme, photo mode. Phone speed pass. Store listing prep | 20, 31, 32, 33, 34, 35 |

Counting toward 300 collectibles: 30 per biome across 10 biomes.

Item 37 rides along with the art it covers: ship and add-on sheets in Release 5, enemy and boss sheets in each release that adds them (Releases 4 and 6 to 9).

## Unfinished standards items (2026-11-15)

From the Open items in `STANDARDS_OVERRIDES.md`, plus what has not been tried on a real device. Each line comes off when it is done. BC picks when.

- G7.5: not tested on a real phone, a real controller or with sound on.
- E1.2: `world_view.gd` and `hud.gd` reach `main.gd` through a plain `Node2D` reference, so those reads are not type checked.
- E3.1, E4.6: draw calls and memory not measured on a device.
- E5.5: the split frame step not checked on a slow phone.
- E6.2: sound not heard. The tests ran headless.

## Later

- Google Play listing, after v1.0.0 and only when BC says so.
- Shared HUD pieces in the kit, when a second game needs them (G10.5).

## Not planned (they break the pillars)

- Losing finds, crystals or progress on defeat.
- Leaderboards or play against other people.
- Ads or paid items. The shop uses coins found in play only.

## Decisions from BC

- 2026-11-15: a new game in the style of Minishoot' Adventures, in Godot, on the shared standards, with an override file for the shooter parts.
- 2026-11-15: use best judgment for the MVP release.
- 2026-11-15: one biome only for the first versions, until the gameplay is good. The meadow keeps its cave and boss.
- 2026-11-15: add the game to The Game Shelf with every update, in the same format as the other games.
- 2026-11-15: the name is Tiny Tailwind.
- 2026-11-15: bigger shots, and best judgment on quality of life for the next release.
- 2026-11-15: move to Release 2, coins and the shop, after the new ship.
- 2026-11-15: a new default ship shape, the Swallow glider, released on its own as v0.2.1, then Release 2.
- 2026-11-15: backlog items 1 to 12, a list of suggested items and a plan over 10 releases.
- 2026-11-15: a reference spec sheet for the Swallow glider (Gemini views, then a Meshy 3D model), and spec sheets for enemies, new ships and more added as item 37.
- 2026-11-15: render the Meshy 3D Swallow ship into sprites for the 2D game, as its own release. This is an exception to the rule that all art is drawn in code. Shipped in v0.3.1.
- 2026-11-15: the Swallow did not look good in game. Start over with something closer to the compact top-down ships of the genre, but original. Picked the Manta concept at 60 px and the Meshy render. Shipped in v0.3.2.
- 2026-11-15: a closer camera and less thrust from the back of the ship. Shipped in v0.3.3.
- 2026-11-16: the catch-up builds on v0.3.4 main. The graphics branches merge in later.
- 2026-11-15: all seven suggested QoL items in the next release unless they need splitting. Six shipped in v0.3.4. Standard Settings and save slots go with the standards catch-up release, since they come from kit 1.8.0.

## Judgment calls made in v0.3.6 (BC to confirm or change)

1. A patch number (v0.3.6) for a sound fix only. No other change rides along.
2. The engineering rule Home by Dusk proposed (E6.8: buses come from `default_bus_layout.tres`, never `AudioServer.add_bus()` at runtime, and every release measures real page sound) stays Proposed. Not in force until BC approves it.
3. The sound test lives in this game's `tests/` for now, not in the shared kit. Moving it to the kit is a kit change for BC to approve.
4. The sound test checks one moment: the first click and Enter on the title card. It does not walk every area.

## Judgment calls made in v0.3.5 (BC to confirm or change)

1. Version 0.3.5, not 0.4.0. The roadmap keeps v0.4.0 for weapons. The Scenic Route took a patch number for its catch-up too.
2. Built on v0.3.4 main, not on the graphics branches (BC, 2026-11-16).
3. Every option moved into the device Settings, Difficulty and the assists too, so all slots share them (G5.11). The save keeps the old fields for old builds.
4. Screen shake is On or Off now. An old Low setting becomes On, which is the full shake.
5. Choosing a slot rebuilds the world and starts play there at once, as The Scenic Route does.
6. No Quit button on the title card. The browser cannot close, and Android closes from the system.
7. Rumble now buzzes the phone too, on by default, as the standard says. The APK asks for the vibration permission.
8. The new icon shows the Manta, rendered from BC's model, climbing on a golden tailwind over a night meadow. The old icon still showed the Swallow glider.
9. The Settings About line credits the music and names the privacy page.

## Judgment calls made for v0.1.0 (BC can change any)

- Name: Tiny Tailwind, chosen by BC on 2026-11-15 after seeing the overlap notes (a space shooter called Tailwind: Prologue exists, and the name sits near Tiny Titans Football).
- Look: 2D, drawn in code. The ship became sprites from a 3D model in v0.3.1 (BC's ask), and the Manta in v0.3.2.
- Signing: the real key from `game-signing`.
- Overrides 3 to 7 in `STANDARDS_OVERRIDES.md`.
- Default difficulty is Normal. Auto aim is off by default.
