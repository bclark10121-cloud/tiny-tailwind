#!/usr/bin/env python3
# Xbox controller check (G5.8): plays from the title card into the game and through every Menu page with only the kit's
# pretend Xbox controller. No key, mouse or touch is used. Must print errors [].
# usage: pad_test.py [web build folder] [shots folder]
import asyncio, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "common"))
from webkit import Run, serve
OUT = sys.argv[1] if len(sys.argv) > 1 else "../tiny-tailwind-out/web"
SHOTS = sys.argv[2] if len(sys.argv) > 2 else "../tiny-tailwind-out/shots-pad"
TITLE, PLAY, DEFEAT, FADE_OUT, FADE_IN, END = range(6)

async def main():
    with serve(OUT, 8796) as base:
        async with Run("tinytailwind", SHOTS) as r:
            pg = r.page
            await r.use_pad(); await r.open(base + "index.html?test")
            s = await r.wait_phase([TITLE], 90); await pg.wait_for_timeout(2500)
            s = await r.state(); r.check(s["focus"] in ("Start", "Continue"), "title card: the Start button has the focus (%s)" % s["focus"]); await r.shot("01_title_focus")
            await r.pad("A"); s = await r.wait_phase([PLAY], 20); r.check(s.get("phase") == PLAY, "A presses Start")
            x0 = s["x"]; await r.pad_stick(1.0, 0.0, 2000); s = await r.state(); r.check(s["x"] > x0 + 60, "left stick flies the ship: x %.0f to %.0f" % (x0, s["x"]))
            r.check(not s["touch"], "touch controls stay hidden with a controller")
            r.check(s["pads"] >= 1 and s["pad_line"].startswith("Controller: ") and "none seen" not in s["pad_line"], "the game names the controller it sees: %s" % s["pad_line"])
            x0 = s["x"]; await r.pad("LEFT", 1800, 300); s = await r.state(); r.check(s["x"] < x0 - 60, "D-pad flies the ship: x %.0f to %.0f" % (x0, s["x"]))
            await r.pad("MENU"); s = await r.wait_for(lambda s: s["menu"], 10, "Menu opens"); r.check(s["menu"] and s["paused"] and s["focus"] == "Ship", "Menu button opens the Menu with Ship in focus (%s)" % s["focus"]); await r.shot("02_menu_ship")
            for name, tab in (("Journal", "journal"), ("Map", "map"), ("Settings", "settings")):
                await r.pad("RIGHT", 300); s = await r.state(); r.check(s["focus"] == name, "D-pad right moves the focus to %s (%s)" % (name, s["focus"]))
                await r.pad("A", 300); s = await r.wait_for(lambda s: s["tab"] == tab, 10, "page " + tab); r.check(s["tab"] == tab, "A opens the %s page" % name)
            await r.shot("03_settings")
            await r.pad("DOWN", 300); s = await r.state(); r.check(s["focus"].startswith("Difficulty") or s["focus"].startswith("Aim assist"), "D-pad down moves into the Settings buttons (%s)" % s["focus"])
            f0 = s["focus"]; d0, a0 = s["difficulty"], s["focus"]
            await r.pad("A", 300); await pg.wait_for_timeout(400); s = await r.state(); r.check(s["focus"] != f0, "A changes the focused setting: %s to %s" % (f0, s["focus"])); await r.shot("04_setting_changed")
            await r.pad("B", 300); s = await r.wait_for(lambda s: not s["menu"], 10, "Menu closes"); r.check(not s["menu"] and not s["paused"], "B closes the Menu")
            await r.pad("VIEW", 300); s = await r.wait_for(lambda s: s["menu"], 10, "Menu opens"); r.check(s["menu"], "View opens the Menu")
            await r.pad("VIEW", 300); s = await r.wait_for(lambda s: not s["menu"], 10, "Menu closes"); r.check(not s["menu"], "View closes the Menu")
            # dash with A, RB and RT
            await r.cmd("give_dash"); await pg.wait_for_timeout(600)
            for b in ("A", "RB", "RT"):
                await r.wait_for(lambda s: s["dash_cd"] <= 0.0, 10, "dash ready")
                await pg.evaluate("() => window.__pad_axes(-1, 0)"); await pg.wait_for_timeout(200)
                n0 = (await r.state())["dashes"]
                await r.pad(b, 900, 300); s = await r.state(); r.check(s["dashes"] == n0 + 1, "%s dashes (%d to %d)" % (b, n0, s["dashes"]))
                await pg.evaluate("() => window.__pad_axes(0, 0)")
            s = await r.state(); r.check(s["rumbles"] >= 3, "the controller is asked to rumble on each dash (%d)" % s["rumbles"])
            # back to the title card from the Menu row, then in again
            await r.pad("MENU", 300); await r.wait_for(lambda s: s["menu"], 10, "Menu opens")
            for i in range(5):
                s = await r.state()
                if s["focus"] == "Title": break
                await r.pad("RIGHT", 300)
            s = await r.state(); r.check(s["focus"] == "Title", "the focus reaches Title on the Menu row (%s)" % s["focus"])
            await r.pad("A", 300); s = await r.wait_phase([TITLE], 10); r.check(s.get("phase") == TITLE and s["focus"] == "Continue", "A on Title returns to the title card with Continue in focus"); await r.shot("05_title_again")
            await r.pad("A", 300); s = await r.wait_phase([PLAY], 10); r.check(s.get("phase") == PLAY, "A presses Continue")
            # the end card
            await r.cmd("heal"); await r.cmd("warp_boss"); await r.wait_for(lambda s: s["map"] == "dungeon" and s["phase"] == PLAY, 30, "keep loads")
            await pg.evaluate("() => window.__pad_axes(1, 0)"); s = await r.wait_for(lambda s: s["arena"] == "d_boss", 20, "warden fight"); await pg.evaluate("() => window.__pad_axes(0, 0)")
            await r.cmd("boss_low"); await r.cmd("win"); s = await r.wait_phase([END], 40); await pg.wait_for_timeout(800)
            s = await r.state(); r.check(s["focus"] == "Keep exploring", "end card: Keep exploring has the focus (%s)" % s["focus"]); await r.shot("06_end_card")
            await r.pad("A", 300); s = await r.wait_phase([PLAY], 10); r.check(s.get("phase") == PLAY, "A closes the end card")
    print(r.report())
asyncio.run(main())
