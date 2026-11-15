# Tiny Tailwind: backlog

Updated 2026-11-15 for v0.3.2. Brian decides the order.

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

- v0.1.1 (2026-11-15). Brian could not fly the ship with the controller in a browser on his ROG handheld. The D-pad now flies the ship. The title card and Settings name the controller the game sees. The game page has handheld steps. Cause found by Brian: the handheld was in PC mode. Gamepad mode fixed it.
- v0.1.2 (2026-11-15). Brian found movement very choppy. The map is now drawn once, so the game's own work per frame dropped from about 20 ms to under 2 ms in a slow test browser. The ship eases into moves, slides around wall corners and the camera eases. A Frame rate setting shows the frames a second.
- v0.2.0 (2026-11-15), the Feel release. Brian found v0.1.2 much smoother and asked for bigger shots, then for best judgment on quality of life. Bigger shots, aim assist levels, a corner mini map, enemy health bars, a low health warning, auto pause, screen shake, rumble and touch stick settings.
- v0.2.1 (2026-11-15). Brian asked for a different default ship shape and picked the Swallow glider from four options. The ship turns smoothly toward the aim. New app icon.
- v0.3.0 (2026-11-15), Release 2: coins and the shop. Coins from enemies, trees and breakable bushes, crystals and pots. 10 hidden coin caches. Wren's Wagon with 7 items: Repair kit, Heart seed, Spare part, Coin magnet, Shield charm, Quick dash and Treasure map.
- v0.3.1 (2026-11-15). Brian asked for a 3D modeled ship. The Swallow glider got Gemini reference views, a Meshy 3D model and a spec sheet. The game now draws the ship from five sprites rendered from that model. It banks into turns and sideways moves. Gameplay did not change.
- v0.3.2 (2026-11-15). Brian found the Swallow glider did not look good in game. A new ship, the Manta: Gemini drew four top-down concepts, each tested at game size on grass and stone. Brian picked the Manta, and the Meshy 3D render over the flat drawing in a side by side game build. 60 px across, a wide rounded ray shape in sky blue and orange.

## Now

- Brian plays v0.3.2 and reports how the Manta looks and feels, and how coins and prices feel.
- Next is Release 3, weapons (v0.4.0), unless Brian picks something else.

## Asked for by Brian, not built yet

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

## Ideas to choose from (Brian picks by number)

Suggested 2026-11-15. Each has a place in the roadmap. Brian can move or drop any of them.

13. Corner mini map, with a toggle. Done in v0.2.0.
14. Fast travel between checkpoints.
15. Lost friends to rescue. Each one opens something in a home village: the shop, the hangar, the paint stall.
16. More gate abilities: a boost that skims water, a bomb that opens cracked walls and a shield.
17. Charged super shot on a second button.
18. Elite enemies and mini bosses.
19. Challenge rooms with a personal best time.
20. Boss rush, unlocked after the last boss.
21. Stamp card of achievements.
22. Three save slots.
23. Controller rumble and a screen shake setting. Done in v0.2.0.
24. Aim assist strength setting, between off and full auto aim. Done in v0.2.0.
25. Scenery that breaks: bushes, pots and crates. Done in v0.3.0 (bushes, pots and cave crystals).
26. Day and night, and weather per biome.
27. Music per biome and a theme per boss.
28. A short story intro and friends who talk.
29. Find hints: a soft ping when a find is near.
30. Touch settings: stick size, left-handed layout and a fixed stick option. Done in v0.2.0 (stick size only. Left-handed and fixed sticks still open).
31. Color-safe shot colors for color blind players.
32. Christmas theme toggle (G4.5).
33. A helper drone that shoots with you.
34. New Game Plus.
35. Photo mode.
36. Enemy journal: a page for each enemy you have beaten.

## Roadmap: 10 releases

Order of thought: feel first, then the money loop, then things to collect and wear, then the world grows. Biome 2 waits until the gameplay is good (Brian, 2026-11-15).

| Release | Theme | What is in it | Backlog items |
|---|---|---|---|
| 1. v0.2.0, done | Feel | Fixes from Brian's playtest. Tuning of speed, shots and enemies. Better hit and hurt feedback. Aim assist strength, rumble, shake setting, touch settings, corner mini map. Still one biome | 13, 23, 24, 30 |
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

## Later

- Google Play listing, after v1.0.0 and only when Brian says so.
- Shared HUD pieces in the kit, when a second game needs them (G10.5).

## Not planned (they break the pillars)

- Losing finds, crystals or progress on defeat.
- Leaderboards or play against other people.
- Ads or paid items. The shop uses coins found in play only.

## Decisions from Brian

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

## Judgment calls made for v0.1.0 (Brian can change any)

- Name: Tiny Tailwind, chosen by Brian on 2026-11-15 after seeing the overlap notes (a space shooter called Tailwind: Prologue exists, and the name sits near Tiny Titans Football).
- Look: 2D, drawn in code. The ship became sprites from a 3D model in v0.3.1 (Brian's ask), and the Manta in v0.3.2.
- Signing: the real key from `game-signing`.
- Overrides 3 to 7 in `STANDARDS_OVERRIDES.md`.
- Default difficulty is Normal. Auto aim is off by default.
