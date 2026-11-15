#!/usr/bin/env python3
# Browser check (G7.3, G7.6): the web build loads with no errors, the title card shows, the ship flies and shoots,
# the Menu row and its four pages open, touch controls appear, the cave and keep load, defeat returns to a checkpoint,
# the warden fight ends on the end card, and progress survives a reload.
# The game publishes window.tinytailwind only with the whole-word ?test flag (G7.8).
# usage: web_test.py [web build folder] [shots folder]
import asyncio, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "common"))
from webkit import Run, serve
OUT = sys.argv[1] if len(sys.argv) > 1 else "../tiny-tailwind-out/web"
SHOTS = sys.argv[2] if len(sys.argv) > 2 else "../tiny-tailwind-out/shots"
TITLE, PLAY, DEFEAT, FADE_OUT, FADE_IN, END = range(6)

async def main():
    with serve(OUT, 8795) as base:
        async with Run("tinytailwind", SHOTS) as r:
            pg = r.page
            # without ?test the page must publish nothing (G7.8)
            await r.open(base + "index.html?contest"); await pg.wait_for_timeout(9000)
            r.check(await r.state() is None, "no test state without the whole-word ?test flag")
            await r.open(base + "index.html?test")
            s = await r.wait_phase([TITLE], 90); await pg.wait_for_timeout(2500); await r.shot("01_title")
            r.check(s.get("version") == "0.1.1", "title card up, version %s" % s.get("version"))
            r.check("none seen yet" in s["pad_line"], "with no controller the title card says so")
            await r.key("Enter"); s = await r.wait_phase([PLAY]); await pg.wait_for_timeout(1200); await r.shot("02_start")
            x0 = s["x"]
            await pg.keyboard.down("d"); await pg.keyboard.down("ArrowRight"); fired = await r.wait_for(lambda s: s["shots"] > 0, 10, "a shot in flight"); await pg.wait_for_timeout(2000)
            s = await r.state(); s["shots"] = max(s["shots"], fired.get("shots", 0)); await r.shot("03_fly_and_shoot")
            await pg.keyboard.up("d"); await pg.keyboard.up("ArrowRight")
            r.check(s["x"] > x0 + 60, "the ship flew right: x %.0f to %.0f" % (x0, s["x"]))
            r.check(s["shots"] > 0, "shots in flight: %d" % s["shots"])
            await r.cmd("warp_cross"); await r.wait_for(lambda s: s["phase"] == PLAY and s["x"] > 1400, 30, "warp to the crossroads")
            await pg.keyboard.down("ArrowRight"); await pg.wait_for_timeout(3500); await r.shot("04_crossroads_fight"); await pg.keyboard.up("ArrowRight")
            s = await r.state(); r.notes.append("crossroads: kills %s awake %s hp %s" % (s["kills"], s["awake"], s["hp"]))
            # menu row and pages
            await r.key("Escape", 700); s = await r.state(); r.check(s["menu"] and s["paused"], "Esc opens the Menu and pauses"); await r.shot("05_menu_ship")
            await r.cmd("xp"); await r.cmd("tab_ship"); await pg.wait_for_timeout(500); await r.shot("06_ship_points")
            for t in ("journal", "map", "settings"):
                await r.cmd("tab_" + t); await pg.wait_for_timeout(700); s = await r.state(); r.check(s["tab"] == t, "page %s opens" % t); await r.shot("07_menu_" + t)
            await r.key("Escape", 500); s = await r.state(); r.check(not s["menu"] and not s["paused"], "Esc closes the Menu")
            # touch controls show on touch and hide on a key (E5.4)
            cdp = await r.touch_drag(200, 520, 260, 500, 900); s = await r.state(); r.check(s["touch"], "touch controls show on a touch"); await r.shot("08_touch")
            await r.touch_end(cdp); await r.key("a", 400); s = await r.state(); r.check(not s["touch"], "touch controls hide on a key")
            # cave and the dash
            await r.cmd("heal"); await r.cmd("warp_core"); await r.wait_for(lambda s: s["map"] == "cave" and s["phase"] == PLAY, 30, "cave loads"); await pg.wait_for_timeout(1500); await r.shot("09_cave")
            await r.cmd("give_dash"); await pg.wait_for_timeout(900); s = await r.state(); r.check(s["dash"], "the Dash Core gives the dash"); await r.shot("10_dash_found")
            x0 = s["x"]; await pg.keyboard.down("d"); await r.key("Space", 500); await pg.keyboard.up("d"); s = await r.state(); r.notes.append("dash moved x %.0f to %.0f" % (x0, s["x"]))
            # defeat costs nothing
            f0, l0 = s["finds"], s["level"]
            await r.cmd("defeat"); await r.wait_phase([DEFEAT], 10); await pg.wait_for_timeout(900); await r.shot("11_defeat")
            s = await r.wait_phase([PLAY], 20); r.check(s["hp"] == s["max_hp"] and s["finds"] == f0 and s["level"] == l0, "defeat returns to a checkpoint with full hearts and nothing lost")
            # the keep and the warden
            await r.cmd("heal"); await r.cmd("warp_dungeon"); await r.wait_for(lambda s: s["map"] == "dungeon" and s["phase"] == PLAY, 30, "keep loads"); await pg.wait_for_timeout(1500); await r.shot("12_keep")
            await r.cmd("warp_boss"); await r.wait_for(lambda s: s["map"] == "dungeon" and s["x"] > 2200 and s["phase"] == PLAY, 30, "boss door")
            await pg.keyboard.down("d"); s = await r.wait_for(lambda s: s["arena"] == "d_boss", 20, "warden fight starts"); await pg.keyboard.up("d")
            r.check(s.get("arena") == "d_boss", "the gates close and the warden wakes")
            await pg.keyboard.down("ArrowRight"); await pg.wait_for_timeout(5000); await r.shot("13_warden"); 
            await r.cmd("boss_low"); s = await r.wait_for(lambda s: "d_boss" in s["flags"], 40, "warden calmed"); await pg.keyboard.up("ArrowRight")
            r.check("d_boss" in s.get("flags", []), "the warden is calmed")
            s = await r.wait_phase([END], 30); await pg.wait_for_timeout(900); await r.shot("14_end_card")
            await r.key("Enter", 600); s = await r.state(); r.check(s["phase"] == PLAY, "the end card closes back to play")
            # the save survives a reload (E6.4)
            await r.key("Escape", 500); await r.key("Escape", 500)
            took = await r.wait_saved(['"d_boss"', '"c_dash"']); r.notes.append("save reached browser storage in %.0f s" % took)
            await pg.goto(base + "index.html?test"); s = await r.wait_phase([TITLE], 90); await pg.wait_for_timeout(1500); await r.shot("15_title_after_reload")
            r.check(s["dash"] and "d_boss" in s["flags"], "progress survives a reload")
            # phone-size screen with a pretend notch (E5.3)
            await pg.set_viewport_size({"width": 844, "height": 390}); await pg.goto(base + "index.html?test&notch"); await r.wait_phase([TITLE], 90); await pg.wait_for_timeout(1500); await r.shot("16_phone_title")
            await r.cmd("start"); await r.wait_phase([PLAY]); cdp = await r.touch_drag(120, 300, 160, 280, 900); await r.shot("17_phone_touch"); await r.touch_end(cdp)
            await r.cmd("menu"); await pg.wait_for_timeout(700); await r.shot("18_phone_menu")
    print(r.report())
asyncio.run(main())
