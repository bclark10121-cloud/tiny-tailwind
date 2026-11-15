# Tiny Tailwind: backlog

Updated 2026-11-15 for v0.1.1. Brian decides the order.

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

- v0.1.1 (2026-11-15). Brian could not fly the ship with the controller in a browser on his ROG handheld. The D-pad now flies the ship. The title card and Settings name the controller the game sees. The game page has handheld steps.

## Now

- Brian plays v0.1.0 and reports how it feels. Release 1 below starts from his notes.

## Asked for by Brian, not built yet

Asked 2026-11-15. The release each one lands in is shown in the roadmap.

1. 10 biomes.
2. 300 collectibles.
3. Hidden rooms.
4. 10 boss battles.
5. New weapon types to find.
6. New weapon upgrades to find.
7. A shop with items to buy.
8. Coins to find around the biomes to buy things.
9. Shooting trees and enemies makes them drop coins the ship picks up.
10. New ships.
11. New ship add-ons.
12. New paint colors for ships.

## Ideas to choose from (Brian picks by number)

Suggested 2026-11-15. Each has a place in the roadmap. Brian can move or drop any of them.

13. Corner mini map, with a toggle.
14. Fast travel between checkpoints.
15. Lost friends to rescue. Each one opens something in a home village: the shop, the hangar, the paint stall.
16. More gate abilities: a boost that skims water, a bomb that opens cracked walls and a shield.
17. Charged super shot on a second button.
18. Elite enemies and mini bosses.
19. Challenge rooms with a personal best time.
20. Boss rush, unlocked after the last boss.
21. Stamp card of achievements.
22. Three save slots.
23. Controller rumble and a screen shake setting.
24. Aim assist strength setting, between off and full auto aim.
25. Scenery that breaks: bushes, pots and crates.
26. Day and night, and weather per biome.
27. Music per biome and a theme per boss.
28. A short story intro and friends who talk.
29. Find hints: a soft ping when a find is near.
30. Touch settings: stick size, left-handed layout and a fixed stick option.
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
| 1. v0.2.0 | Feel | Fixes from Brian's playtest. Tuning of speed, shots and enemies. Better hit and hurt feedback. Aim assist strength, rumble, shake setting, touch settings, corner mini map. Still one biome | 13, 23, 24, 30 |
| 2. v0.3.0 | Coins and the shop | Coins hidden around the biome. Trees, bushes and enemies drop coins when shot. A shop with items to buy. Scenery that breaks | 7, 8, 9, 25 |
| 3. v0.4.0 | Weapons | New weapon types to find, such as a spread shot, a piercing shot and a homing shot. Weapon upgrades to find. A charged super shot | 5, 6, 17 |
| 4. v0.5.0 | Secrets | Hidden rooms and cracked walls. Finds in the first biome rise to 30. Find hints. Enemy journal. Elite enemies | 3, 18, 29, 36, part of 2 |
| 5. v0.6.0 | The hangar | New ships with their own strengths. Ship add-ons. Paint colors. Three save slots | 10, 11, 12, 22 |
| 6. v0.7.0 | Biome 2 | The second biome with its cave, keep and boss. A new gate ability. Lost friends and the home village. Fast travel | 14, 15, 16, part of 1, 2 and 4 |
| 7. v0.8.0 | Biomes 3 and 4 | Two more biomes and bosses. Music per biome. Day, night and weather | 26, 27, part of 1, 2 and 4 |
| 8. v0.9.0 | Biomes 5 to 7 | Three more biomes and bosses. Mini bosses. Challenge rooms. Stamp card | 19, 21, part of 1, 2 and 4 |
| 9. v0.10.0 | Biomes 8 to 10 | The last three biomes and bosses. 10 biomes, 10 bosses and 300 collectibles complete. An ending | 1, 2, 4 complete, 28 |
| 10. v1.0.0 | Finish | Boss rush, New Game Plus, helper drone, color-safe shots, Christmas theme, photo mode. Phone speed pass. Store listing prep | 20, 31, 32, 33, 34, 35 |

Counting toward 300 collectibles: 30 per biome across 10 biomes.

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
- 2026-11-15: backlog items 1 to 12, a list of suggested items and a plan over 10 releases.

## Judgment calls made for v0.1.0 (Brian can change any)

- Name: Tiny Tailwind, chosen by Brian on 2026-11-15 after seeing the overlap notes (a space shooter called Tailwind: Prologue exists, and the name sits near Tiny Titans Football).
- Look: 2D, drawn in code.
- Signing: the real key from `game-signing`.
- Overrides 3 to 7 in `STANDARDS_OVERRIDES.md`.
- Default difficulty is Normal. Auto aim is off by default.
