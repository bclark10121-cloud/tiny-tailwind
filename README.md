# Tiny Tailwind

A twin-stick adventure shooter for the browser and Android. Fly a small ship through the Sunmeadow, find 20 keepsakes, win the dash in Echo Hollow and calm the warden of Thornkeep.

- Game page: https://bclark10121-cloud.github.io/tiny-tailwind/
- More games: https://bclark10121-cloud.github.io/

Made with Godot 4.6. All art is drawn in code. Defeat costs nothing and assists are in the Menu.

## Layout

| Path | What it is |
|---|---|
| `scripts/` | The game: `main.gd` (rules of play), `world_view.gd` (drawing), `hud.gd` (HUD and menus), `bot.gd` (test bot), `enemy.gd` |
| `data/` | The world, enemies and finds as data |
| `tools/` | `make_world.py` and `make_sfx.py`, plus the shared kit in `tools/common/` |
| `tests/` | The browser test, plus the shared kit in `tests/common/` |
| `docs/` | The game page, the browser build, the APK and release notes |
| `BACKLOG.md` | What is done, what is asked for and the roadmap |
| `STANDARDS_OVERRIDES.md` | Where this game differs from the shared standards |
| `CREDITS.md` | Outside assets and their licences |
