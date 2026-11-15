# Tiny Tailwind: standards overrides

Standards: `GAME_STANDARDS.md` (rule ids start with G) and `ENGINEERING_STANDARDS.md` (rule ids start with E) in the private repo `bclark10121-cloud/game-standards`. This repo holds no copies.
This file lists where this game does something else, and why. A rule not listed here applies in full.
Order of authority: Brian in the chat, then this file, then the standards.

Last reviewed: v0.1.1 (2026-11-15).
Checked against: game-standards version 2026-11-15 with G5.8 (commit b2c2865). Shared kit 1.5.0 (`common.lock`).

On 2026-11-15 Brian said a shooter has enemies and dying, that an overrides file should cover what does not fit, and to use best judgment for the MVP. Rows agreed under that instruction say "delegated". Brian can change any of them.

## Overrides

| # | Rule | Standard says | This game does | Why | Ends when | Agreed |
|---|---|---|---|---|---|---|
| 1 | G4.1 | Calm games. No combat. No way to lose. A reset never costs anything | A shooter with enemies, hearts and defeat. Defeat returns the ship to the last checkpoint with full hearts. Nothing is lost: finds, level, crystals and cleared rooms all stay | Brian asked for a shooter in the style of Minishoot' Adventures | Never, unless Brian changes the kind of game | 2026-11-15 |
| 2 | G4.4 | Records and achievements are personal bests only. No leaderboards, no opponents | Computer enemies and a boss. The only record is a personal best time for the boss, saved on the device. No leaderboards | Same reason as row 1 | Never, unless Brian changes the kind of game | 2026-11-15 |
| 3 | G5.2 | Nothing sits on screen while playing except the status readout, the find counter and touch controls | Hearts, the level bar, the dash bar and the find counter at the top left. The boss bar at the bottom during the boss fight | A shooter needs health and cooldowns in view | G5.2 is widened, or Brian asks for less | 2026-11-15, delegated |
| 4 | G5.3 | Touch: steer by dragging on the left half. Action buttons on the right | Two thumbs. Drag on the left half to move. Drag on the right half to aim and fire. A Dash button on the right | Twin-stick play needs a second stick for aim | No end planned | 2026-11-15, delegated |
| 5 | G7.1 | A headless test driver proves the main route is drivable with 0 resets | A headless bot plays the whole route: every find, the cave, the dash, the keep and the boss. It must print `BOT done` | There is no road to drive. A defeat is part of play, so the bot reports its defeat count instead of 0 resets | G7.6 comes into force and covers this | 2026-11-15, delegated |
| 6 | E4.1 | The default is GodotPhysics3D. A game with no physics engine records an override | No physics engine. The ship, enemies and shots move with plain maths on a tile grid | Hundreds of shots stay cheap on phones and results match on every device | The game adds physics bodies | 2026-11-15, delegated |
| 7 | E2, E3, E4.2, E4.3, E5.2 | Godot 3D rules: 3D particles, materials, lights, triangle budgets, MultiMeshInstance3D, physics interpolation, primitive 3D colliders, 3D render scale | This is a 2D game. All art is drawn in code with no textures, lights or materials. Shots, sparks and pickups are pooled arrays drawn in one pass. The Compatibility renderer (E2.1) and the pooling rule (E4.5) apply in full | The engineering standards are written for 3D. Their intent (cheap drawing, no work made during play) is met in 2D | The standards gain a 2D section | 2026-11-15, delegated |

A Proposed row is not in force. The standard applies until Brian agrees.

## Open items (rule applies, work not finished)

- G4.2: the four pillars in `CLAUDE.md` are proposed. Brian to confirm.
- G5.8: Brian reported on 2026-11-15 that the controller did not fly the ship in a browser on his ROG handheld. v0.1.1 adds D-pad flying and a line that names the controller the game sees. The likely cause is the handheld's Desktop control mode. Not confirmed on the device yet.
- G7.5: not tested on a real phone, a real controller or with sound on. All tests ran headless.
- E1.2: every declaration is typed. `world_view.gd` and `hud.gd` reach `main.gd` through a plain `Node2D` reference, so those reads are not type checked.
- E1.3: the HUD checks its message timer every frame. The world redraws every frame while the title card is up. Sleeping enemies are skipped.
- E1.4: no node lookups in loops. Met, listed here because it was checked by reading only.
- E3.1 and E4.6: draw calls and memory are not measured on a device. The whole game draws with rectangles, circles and polygons and loads three music tracks on demand.
- E5.5 (Proposed rule): the frame step is capped and split into up to three steps. Not checked on a slow phone.
- E6.2: music and sounds start after the first input. Checked in code. Sound was not heard in the headless tests.

## Rules met

Checked on 2026-11-15 by reading the files and by running the checks named in `CLAUDE.md`.

Game standards: G0.3, G0.10, G0.12, G1.1, G1.2, G1.3, G1.4, G1.5, G1.6, G1.7, G1.8, G1.9 (`SECRETS check ok`), G1.10, G1.11, G2.1 to G2.7, G3.1 to G3.5, G4.3 (20 finds, counter, journal, save, messages one third of the way down), G4.6, G5.1, G5.4, G5.5, G5.6, G5.8 (the whole game plays with only an Xbox controller, Xbox button names on the title card and game page, connect steps on the game page, `tests/pad_test.py` prints `errors []`), G6.1, G6.2, G6.3 (signature starts with `5db69ffb`), G6.4, G6.6 (walls, water, rifts and gates all block by tile), G7.2 (`REACH ok 20/20`), G7.3, G7.4, G7.8, G8.1, G8.3, G8.4, G10.2, G10.3 (`COMMON check ok: 1.5.0 b2c2865`), G10.4, G10.8.

Proposed rules the game already follows: G4.8 (review, plan and name check before the build), G4.9 (content as data), G7.6 (the browser test reads the game state), G7.7.

Engineering standards: E1.1, E1.5, E2.1, E4.5, E5.1, E5.3 (HUD reads the safe area, checked with a pretend notch in the browser), E5.4 (touch, gamepad and keyboard through input actions, touch controls hide on key or gamepad input, targets 56 px or more), E6.1, E6.3 (music `.ogg` at 112 kbps, sounds mono `.wav` at 22.05 kHz), E6.4, E6.5, E6.6, E6.7 (`SAVESTORE check ok`, ids from a save are checked against the data).

G6.7 (Proposed) was not followed: Brian delegated the MVP, so v0.1.0 is signed with the real key from `game-signing`.

## Not in use in this game

- G4.5: no seasonal theme yet.
- G5.7: the game shows no speeds or distances.
- G6.5: no roads or decals. The game is 2D.
- G8.2: no outside pictures or sounds. Only the music is from outside.
- E4.4: no navigation agents. Enemies steer by plain maths.

## How to add an override

1. Flag the conflict to Brian with the options. Do not override by yourself.
2. Add the row as Proposed and list it as a judgment call in the report to Brian.
3. Once he agrees, put the date in the Agreed column.
4. When an override ends, move its row to Ended overrides with the date.
5. When an override fits every game, ask Brian to make it a standard. Then end the override.

## Ended overrides

None yet.
