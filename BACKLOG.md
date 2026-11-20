# Tiny Tailwind: backlog

Updated 2026-11-20 for v0.8.0. BC decides the order.

## Graphics plan (BC, 2026-11-15)

Research by six agents on 2026-11-15. BC's choices: stay 2D, a clean toy render look (not pixel art), Kenney's CC0 controller icons are fine, Fredoka and Nunito fonts (SIL OFL) are fine. Stay on the Compatibility renderer. Budget on Retroid-class handhelds: 12 ms a frame, under 100 draw calls, 4 to 6 real lights, one full-screen pass, under 128 MB of textures. Warm up effects on the title card.

1. Phase 1, shipped in v0.3.8: soft shadows from one sun, glow halos on shots, pickups and the engine, gentle bloom, a color grade per area and a vignette (Settings > Glow and color), hit stop on kills, hits and the boss, a camera zoom punch on the boss, Nunito and Fredoka fonts.
2. Phase 2, shipped in v0.3.8: a gold ring that closes in before an enemy fires, with a faint aim line for aimed shots. Glowing sparks. A ring that bursts out on each kill and on the warden. A glowing dash trail. A pale damage-lag part on enemy bars and the warden's bar. +1 and +2 numbers on pickups. The Menu and the shop ease in. Left for later: Kenney controller icons (the pack has to come from kenney.nl, which the cloud machine cannot reach, so it needs a download in BC's browser), and a dissolve on death (enemies are drawn in code, so the burst ring stands in for it until they are sprites in Phase 3).
3. Phase 3: a style board, then 64 px dual-grid tiles per area (walls and floors first), then enemies and props rendered from Meshy models with normal maps, mood lights in the cave and the boss arena, animated water with foam, wind sway on grass and trees.
4. Phase 4: paint colors for ships (palette swap), rounded 9-slice menu frames, a restyled minimap, drifting fog and cloud shadows.

## Done

- v0.8.0 (2026-11-20), Release 3: weapons (BC, 2026-11-20: "move forward with your suggestion"). Three weapons to find: the Spread Shot (Sunmeadow), the Pierce Shot (Echo Hollow) and the Homing Shot (Thornkeep). Three Tuning Cores, one per area, make every weapon better. A charged super shot on its own button (LT, E or the Charge button). Swap with Y, Q, the mouse wheel, the Swap button or the Ship page. Finds rise from 20 to 26. Score and best (G4.17, kit `score.gd`) on the HUD and the Records page. Three new achievements. Fixes: the title card read 0.6.3 in v0.7.0, and the leftover 60 frame cap on phones is gone (G6.20). Version code 24. Backlog items 5, 6 and 17 done.

- v0.7.0 (2026-11-19): Godot 4.7.2, kit 1.18.0, G6.20 (no 60 cap, `tests/feel_check.gd`, Show frame rate), full screen by default in the browser, G6.21 wide check. Next: Release 3, weapons (BC's sweep: ready).

- v0.6.3 (2026-11-19): kit K2, the shooter core (BC: "k2, shooter core next", full pull). Shots, the four fire patterns, shake, hit stop, the hurt flash, the zoom punch and the warden's attack cycle now come from the kit `shooter_core.gd` (kit 1.16.0). Play is the same: a before and after bot trace matched. First game on K2.

- v0.6.2 (2026-11-18): start screen title (G5.21 Title, asked for by BC). The name sits in the dead center, above the buttons, in Chewy (Apache License 2.0), on the start screen, the game page and the Game Shelf card. Kit 1.15.0.

- v0.6.1 (2026-11-18): start screen music (G5.21, asked for by BC). The title track is "Aquarium" (Kevin MacLeod, CC BY 4.0), `audio/music_title.ogg`. `play_music()` swaps in the title track while `phase` is TITLE and fades into the room's music on Play. On Android and desktop it starts with the start screen, in a browser on the first press. No two games share a title track.

- v0.5.0 (2026-11-17), Release 7 (standards review, kit 1.12.0): Records page with 11 achievements and 7 stats, Change controls, Battery saver, backup codes, old-save checks, an error log and sound at one loudness level.

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
- v0.3.7 (2026-11-16), laser shot sound (BC 2026-11-16: the shots should sound like a sci-fi laser, not a bullet). BC picked Classic Pew from six laser options. `tools/make_sfx.py` draws it. Each shot gets a small random pitch change. Version code 13.
- v0.3.8 (2026-11-16), the graphics release (BC 2026-11-16: "yes" to moving the two staged graphics branches onto `game-studio` and shipping them). Graphics Phase 1 and Phase 2 from the plan above: glow, bloom, a color grade per area, a vignette, soft shadows, hit stop, a zoom punch on the warden, enemy wind-up rings and aim lines, kill rings, glowing sparks, a dash trail, damage-lag bars, pickup numbers, panels that ease in and the Nunito and Fredoka fonts. A new setting, Glow and color. Gameplay did not change. Version code 14.
- v0.3.9 (2026-11-16), louder pew (BC 2026-11-16: the pew was hard to hear under the music). BC picked a louder pew and quieter music overall. The shot sound is 8 dB louder (-17 to -9 dB) and the music 4 dB quieter at every Music level (-11 to -15 dB). The pew now sits about level with the meadow and cave music, where it was about 10 dB under it. Version code 15.
- v0.3.10 (2026-11-16), sound effects in the browser (BC 2026-11-16: still no pew after v0.3.9, with a hard refresh, the new APK and Sound on). Every sound effect had been silent in the browser since v0.1.0: the Sfx bus in `default_bus_layout.tres` named no send, and with sample playback (`default_playback_type.web=1`) the browser routes such a bus nowhere. Music has a send, so it always played. The Sfx bus now sends to Master. `tests/audio_test.py` now checks that every bus names a send and records the page while the ship fires with the music cut: it fails on v0.3.9 and passes on v0.3.10. Android was not affected. Version code 16.

## Now

- BC's check of v0.8.0: how each weapon and the charged shot feel, the Charge and Swap touch buttons, the score line.
- Next (BC, 2026-11-20, 10:00 AM): the story and visual redesign, the undersea dragon palace theme (item 40, working title Manta Quest: The Lost Pearl). Decision pages first: name, ship, world look, story.
- Still to take from the G4.17 to G4.20 rollout table: G4.18 completion and stars, G4.19 daily goals, G4.20 player level and cosmetic unlocks. Tiny Tailwind is Y on all three. Open items, not overrides.
- Graphics Phase 3 and 4 wait for BC to pick them.

## Asked for by BC, not built yet

Asked 2026-11-15. The release each one lands in is shown in the roadmap.

1. 10 biomes.
2. 300 collectibles.
3. Hidden rooms.
4. 10 boss battles.
5. New weapon types to find. Done in v0.8.0.
6. New weapon upgrades to find. Done in v0.8.0 (Tuning Cores).
7. A shop with items to buy. Done in v0.3.0.
8. Coins to find around the biomes to buy things. Done in v0.3.0.
9. Shooting trees and enemies makes them drop coins the ship picks up. Done in v0.3.0.
10. New ships.
11. New ship add-ons.
12. New paint colors for ships.
37. Spec sheets for more art, like the Swallow glider ship spec: one for each enemy, boss, new ship and ship add-on. Each holds reference views, colors, size, markers and a hitbox. Asked 2026-11-15. Each sheet lands in the release that adds that art.
40. A new theme so the game stops looking like Minishoot' Adventures: an undersea dragon palace from Chinese myth (worked up as "Dragon King's Sea", BC 2026-11-16: likes the idea, not that name). Asked 2026-11-16. Not placed in the roadmap yet. BC picks when.
    - World: under an eastern sea. Coral palaces, sunken temples, jade caves and kelp forests hung with red lanterns. The meadow, Echo Hollow and Thornkeep become a reef, a sea cave and a sunken palace or temple. Walls become coral and rock. Rifts become trenches.
    - Currents take the place of wind. Swimming with one gives a speed burst.
    - Enemies keep their behaviors and get mythic sea looks: lionfish spirits, a turtle general, a crab guardian, a clam that breathes mirages and more.
    - Pickups: coins become pearls, crystals become sea glass or jade, shots become glowing bubble bolts.
    - Ship: keep the Manta as a palace guardian, or a sea dragon hatchling that grows fins and horns with upgrades. BC to pick.
    - Room for 10 sea biomes, such as reef, kelp forest, shipwreck, ice sea, volcanic vents, deep trench, sunken city, mangroves, a glowing abyss and a storm surface.
    - Working title (BC 2026-11-16): Manta Quest: The Lost Pearl. The ship stays the Manta, a palace guardian searching for the Dragon King's lost pearl. Web check 2026-11-16 found no game called Manta Quest. Nearest: Manta (2022), a sci-fi flight and submarine game. Short app label still to pick (the full name is cut off under an icon). Trademark and Play Store not checked.
    - Still open: confirm the name before a rename release. Names starting with Tide, Koi or Lantern are crowded (web check 2026-11-16). A rename touches the page repo, The Game Shelf card, the app ID and the icon, and a new app ID means testers reinstall.
    - Watch: blue water hides blue and cyan shots, so shot colors and color-safe shots need a recheck. Water effects cost frame time on the Retroid. A review by someone with Chinese cultural background is wise, and AI art often mixes in Japanese styles. The theme touches Weapons (v0.4.0) and Graphics Phase 3, so decide it before either starts.
41. Suno music, third in line (BC, 2026-11-16, waits on G8.7). A track per area and a boss track in the undersea theme (item 40), made when the theme lands. Today Stage 2 plays in two areas.

## Ideas to choose from (BC picks by number)

Suggested 2026-11-15. Each has a place in the roadmap. BC can move or drop any of them.

13. Corner mini map, with a toggle. Done in v0.2.0.
14. Fast travel between checkpoints. Done in v0.3.4.
15. Lost friends to rescue. Each one opens something in a home village: the shop, the hangar, the paint stall.
16. More gate abilities: a boost that skims water, a bomb that opens cracked walls and a shield.
17. Charged super shot on a second button. Done in v0.8.0.
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
| 3. v0.8.0, done | Weapons | New weapon types to find, such as a spread shot, a piercing shot and a homing shot. Weapon upgrades to find. A charged super shot | 5, 6, 17 |
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
- 2026-11-16: the ship's shots sound like a sci-fi laser. BC picked option 1, Classic Pew, and a full release now (v0.3.7) instead of waiting for the graphics release.
- 2026-11-16: no pew heard after v0.3.9 either. BC said "yes" to shipping the sound route fix as v0.3.10 and fixing the same route in Lo-Fi League and The Scenic Route. Those two turned out fine (default stream playback falls back to Master). Tiny Titans Football had the bug and got the fix as v0.3.5.
- 2026-11-16: the pew was hard to hear, maybe under the music. BC picked "Louder pew" and "Quieter music overall" (not a pew on every shot, not a separate Shots volume). Shipped in v0.3.9.
- 2026-11-16: "yes" to moving graphics Phase 1 and Phase 2 onto `game-studio` and shipping them as the next release. Shipped in v0.3.8.
- 2026-11-15: all seven suggested QoL items in the next release unless they need splitting. Six shipped in v0.3.4. Standard Settings and save slots go with the standards catch-up release, since they come from kit 1.8.0.
- 2026-11-16: add the undersea dragon palace theme to the backlog as item 40. BC likes the idea, not the name "Dragon King's Sea". Name and ship still open.
- 2026-11-16: working title Manta Quest: The Lost Pearl for item 40. The Manta stays as the ship.

## Judgment calls made in v0.3.10 (BC to confirm or change)

1. A patch number (v0.3.10) for the sound route fix only. Nothing else rides along.
2. The v0.3.9 levels stay: the pew at -9 dB and the music at -15 dB. They were chosen while the pew was silent, so BC should listen and say if the balance needs another change.
3. The recorded pew check lives in this game's `tests/audio_test.py`. A shared version for every game is a kit change for BC to approve.
4. Proposed for the standards: add "every bus in `default_bus_layout.tres` names a send" to the proposed rule E6.8. Not in force until BC agrees.
5. The Game Shelf picture stays as it is: nothing on screen changed.

## Judgment calls made in v0.3.9 (BC to confirm or change)

1. A patch number (v0.3.9) for the two level changes only. Nothing else rides along.
2. 8 dB louder for the pew and 4 dB quieter for the music, so the pew sits about level with the meadow and cave music. The boss music is louder than the others, so the pew still plays about 3 dB under it in the warden fight.
3. The music change applies at every Music level, for every player. Settings files keep the level each player picked.
4. The Game Shelf picture stays as it is: nothing on screen changed.

## Judgment calls made in v0.3.8 (BC to confirm or change)

1. Version 0.3.8, not 0.4.0. The roadmap keeps v0.4.0 for weapons, as in v0.3.5.
2. Phase 1 and Phase 2 ship together in one release, not two.
3. Glow and color moved into the kit Settings panel as this game's thirteenth option, right after Find hints, On by default. The graphics branches had put it on the old Settings page, which v0.3.5 replaced.
4. The title card now reads "Tiny Tailwind" in Fredoka in place of "TINY TAILWIND" in capitals, as the graphics branch built it.
5. The zoom punch follows Screen shake and Reduce motion. Hit stop stays on with Reduce motion, since it holds the picture still and does not move it.
6. A line in the graphics branch's browser test hid the find hint screenshot behind a comment. Fixed.
7. The two graphics branches in the page repo (`staging/graphics-phase1` and `staging/graphics-phase2`) stay until BC says to delete them.
8. The Game Shelf picture and the game page screenshots are new, since the look changed.
9. The browser test still expected version 0.3.6 on the title card. It now reads the version from `main.gd`, so it never goes stale again.
10. Standards 2026-11-16a landed during this release. The look check (G7.11) made no contact sheets: the game has no approved reference art yet (G8.6 is an open item). The screenshots of every area were viewed instead. The style block and reference pictures wait for the next art step, with BC's yes on the block.

## Judgment calls made in v0.3.7 (BC to confirm or change)

1. A patch number (v0.3.7) for the shot sound only. No other change rides along.
2. Classic Pew is drawn by `tools/make_sfx.py` at the game's sound rate (mono 22.05 kHz), so it sounds a little softer on the top end than the 44.1 kHz sample BC heard. Same shape and length (0.16 seconds).
3. The shot keeps its old level (-17 dB) and still sounds on every second shot, as before. The new sound is longer, so the overall loudness stays about the same.
4. Each shot plays at a random pitch within 6 percent up or down. Only the shot uses this. Every other sound keeps its pitch.
5. The Game Shelf picture stays as it is: nothing on screen changed.

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

## v0.4.0 (2026-11-17, Release 6)

- Shipped: the shared start screen (G5.21, kit 1.10.0) with this game's own painted scene (`scripts/title_art.gd`). Continue only when there is something to continue, Play opens the slot list, Settings, Quit off the web. Long key lists, tips and credits left the start screen.

### Judgment calls in v0.4.0 (confirmed by BC 2026-11-19)

1. The controls line on the start screen is cut to the main keys and buttons. How to play keeps the full list.
2. The Game Shelf card shows gameplay (BC, 2026-11-17: picked from three options).

## v0.6.0 (2026-11-18, Release 8, shipped 2026-11-18 on BC's "push out")

- Back at the top (G5.30) and landscape and portrait (G6.18), kit 1.13.0. The game turns with the device (`window/handheld/orientation=6`, the APK reads fullUser).
- Upright, the Menu row drops under the Menu button in two lines of four and the page sits under it. Wide, it stays one line across the top.
- How to play over the title card and Wren's Wagon have Back at the top left. The Wagon's Close at the bottom is gone.
- The dash button sits lower upright (60 percent down the screen, was 44) so the right thumb reaches it.
- `tests/orient_test.py` is the five-size browser check. `tests/look_shot.gd` takes pictures without a browser.

### Judgment calls in v0.6.0 (confirmed by BC 2026-11-19)

1. The camera keeps the same zoom upright. The view is as large as before, turned: less to the sides, more above and below. A zoom out upright would make the ship and enemies smaller.
2. The in-game Menu keeps its row at the top with Resume first and Close at the top right. It gets no separate Back: Resume and Close already sit at the top (G5.30 asks that nothing sits only at the bottom).
3. The Wagon's Close button is now Back at the top left (the kit header names it Back). Esc and B still close it.
4. The end card ("The keep is calm") keeps its one button in the middle. It is a result card, not a full-screen panel.
5. The minimap stays at the top right under the Menu button in both orientations.
6. Upright touch sticks were not tried on a real phone. The dash button height is a guess from the screen layout.
