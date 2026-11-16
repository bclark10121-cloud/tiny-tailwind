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
            r.check(s.get("version") == "0.3.4", "title card up, version %s" % s.get("version"))
            r.check("none seen yet" in s["pad_line"], "with no controller the title card says so")
            await r.key("Enter"); s = await r.wait_phase([PLAY]); await pg.wait_for_timeout(1200); await r.shot("02_start")
            await r.cmd("low"); await pg.wait_for_timeout(900); s = await r.state(); r.check(s["hp"] == 1 and s["phase"] == PLAY, "one heart left shows the low health warning"); await r.shot("02b_low_health"); await r.cmd("heal")
            x0 = s["x"]
            await pg.keyboard.down("d"); await pg.keyboard.down("ArrowRight"); fired = await r.wait_for(lambda s: s["shots"] > 0, 10, "a shot in flight"); await pg.wait_for_timeout(2000)
            s = await r.state(); s["shots"] = max(s["shots"], fired.get("shots", 0)); await r.shot("03_fly_and_shoot")
            await pg.keyboard.up("d"); await pg.keyboard.up("ArrowRight")
            r.check(s["x"] > x0 + 60, "the ship flew right: x %.0f to %.0f" % (x0, s["x"]))
            r.check(s["shots"] > 0, "shots in flight: %d" % s["shots"])
            r.check(s["shot_r"] >= 9.0, "player shots are the bigger size: radius %.1f" % s["shot_r"])
            r.check(s["mini"], "the corner mini map shows while playing")
            r.check(s["aim_assist"] == 1, "aim assist starts on Light")
            await r.cmd("warp_cross"); await r.wait_for(lambda s: s["phase"] == PLAY and s["x"] > 1400, 30, "warp to the crossroads")
            await pg.keyboard.down("ArrowRight"); await pg.wait_for_timeout(3500); await r.shot("04_crossroads_fight"); await pg.keyboard.up("ArrowRight")
            s = await r.state(); r.notes.append("crossroads: kills %s awake %s hp %s" % (s["kills"], s["awake"], s["hp"]))
            # low health warning and enemy health bars
            # quality of life settings
            await r.cmd("set_minimap"); await pg.wait_for_timeout(500); s = await r.state(); r.check(not s["mini"] and not s["minimap"], "Mini map setting hides the mini map")
            await r.cmd("set_minimap"); await pg.wait_for_timeout(500); s = await r.state(); r.check(s["mini"], "Mini map setting shows it again")
            for i in range(3): await r.cmd("set_aim_assist", 900)
            s = await r.state(); r.check(s["aim_assist"] == 0, "Aim assist cycles Light, Strong, Auto fire, Off (%d)" % s["aim_assist"])
            await r.cmd("set_aim_assist", 900); s = await r.state(); r.check(s["aim_assist"] == 1, "Aim assist back on Light")
            # v0.3.4: camera setting, edge markers and color-safe shots
            await r.cmd("heal"); s = await r.state(); r.check(s["zoom_set"] == 0 and s["zoom"] > 1.3, "the camera starts Close (zoom %.2f)" % s["zoom"])
            r.check(s["markers"] >= 1, "edge markers point to enemies off screen or the next goal (%d)" % s["markers"]); await r.shot("04a_markers")
            await r.cmd("set_zoom", 2500); s = await r.state(); r.check(s["zoom_set"] == 1 and s["zoom"] < 1.08, "Camera: Normal eases the view out (zoom %.2f)" % s["zoom"]); await r.shot("04a_camera_normal")
            await r.cmd("set_zoom", 2500); s = await r.state(); r.check(s["zoom_set"] == 0 and s["zoom"] > 1.3, "Camera: Close eases back in (zoom %.2f)" % s["zoom"])
            await r.cmd("set_markers", 600); s = await r.state(); r.check(s["markers"] == 0, "the Edge markers setting hides the markers")
            await r.cmd("set_markers", 600); s = await r.state(); r.check(s["markers"] >= 1, "the Edge markers setting shows them again (%d)" % s["markers"])
            await r.cmd("set_safe_colors", 300); await r.cmd("heal"); await pg.keyboard.down("ArrowRight"); await pg.wait_for_timeout(1500); await r.shot("04b_color_safe"); await pg.keyboard.up("ArrowRight")
            s = await r.state(); r.check(s["safe_colors"], "Shot colors switch to Color-safe")
            await r.cmd("set_safe_colors", 700); s = await r.state(); r.check(not s["safe_colors"], "Shot colors switch back to Standard")
            # auto pause when the game loses focus
            await r.cmd("heal"); s = await r.wait_for(lambda s: s["phase"] == PLAY and not s["menu"], 20, "back in play before auto pause"); r.notes.append("before auto pause: phase %s menu %s hp %s" % (s["phase"], s["menu"], s["hp"]))
            await r.cmd("focus_out"); s = await r.wait_for(lambda s: s["menu"], 10, "auto pause opens the Menu"); r.check(s["menu"] and s["paused"], "leaving the game opens the Menu and pauses")
            r.check(not s["mini"], "the mini map hides while the Menu is open")
            await r.key("Escape", 500); s = await r.state(); r.check(not s["menu"], "Esc closes it again")
            # breakables drop coins: shoot the berry bush two tiles to the right
            await r.cmd("heal"); await r.cmd("warp_bush"); await r.wait_for(lambda s: s["phase"] == PLAY and abs(s["x"] - 736) < 40, 30, "next to the bush")
            s = await r.state(); p0, c0 = s["props"], s["coins"]
            await pg.keyboard.down("ArrowRight"); s = await r.wait_for(lambda s: s["props"] < p0, 15, "the bush breaks"); await pg.keyboard.up("ArrowRight")
            r.check(s["props"] == p0 - 1, "shooting a bush breaks it (%d to %d props)" % (p0, s["props"]))
            s = await r.wait_for(lambda s: s["coins"] > c0, 10, "bush coins picked up"); await r.shot("04c_bush_coins")
            r.check(s["coins"] > c0, "the bush drops coins that fly to the ship (%d to %d)" % (c0, s["coins"]))
            # a coin cache
            await r.cmd("warp_cache"); await r.wait_for(lambda s: s["phase"] == PLAY and abs(s["y"] - 1312) < 40, 30, "above the cache")
            s = await r.state(); c0, k0 = s["coins"], s["caches"]
            await pg.keyboard.down("s"); s = await r.wait_for(lambda s: s["caches"] > k0, 10, "cache found"); await pg.keyboard.up("s")
            r.check(s["caches"] == k0 + 1 and s["coins"] >= c0 + 8, "a coin cache adds 8 coins (%d to %d)" % (c0, s["coins"]))
            await r.shot("04d_cache")
            # v0.3.4: a keepsake nearby gives a find hint
            s = await r.state(); h0 = s["hint_pings"]
            await r.cmd("heal"); await r.cmd("warp_find"); s = await r.wait_for(lambda s: s["hint_pings"] > h0, 60, "a find hint")  # the 7 s cooldown runs in game time, which crawls in software drawing; await pg.wait_for_timeout(200); await r.shot("04g_find_hint")
            r.check(s["hint_pings"] > h0, "a keepsake nearby gives a find hint (%d to %d)" % (h0, s["hint_pings"]))
            # Wren's Wagon: fly into the front of the wagon, buy with the keyboard, close with Esc
            await r.cmd("coins_100"); await r.cmd("heal"); await r.cmd("warp_shop"); await r.wait_for(lambda s: s["phase"] == PLAY and abs(s["y"] - 1248) < 40, 30, "below the wagon")
            await pg.keyboard.down("w"); s = await r.wait_for(lambda s: s["shop"], 10, "the shop opens"); await pg.keyboard.up("w")
            r.check(s["shop"] and s["paused"], "flying into the wagon opens the shop and pauses")
            await pg.wait_for_timeout(900); await r.shot("04e_shop")
            s = await r.state(); c0, h0 = s["coins"], s["max_hp"]; r.notes.append("shop focus: %s" % s["focus"])
            await r.key("Enter", 900); s = await r.state()
            r.check(s["coins"] < c0 and sum(s["bought"].values()) >= 1, "Enter buys the focused item (%d to %d coins, bought %s)" % (c0, s["coins"], s["bought"]))
            r.check(s["max_hp"] == h0 + 2, "a Heart seed adds a heart (%d to %d)" % (h0, s["max_hp"]))
            await r.shot("04f_bought")
            await r.key("Escape", 700); s = await r.state(); r.check(not s["shop"] and not s["paused"], "Esc closes the shop")
            # menu row and pages
            await r.key("Escape", 700); s = await r.state(); r.check(s["menu"] and s["paused"], "Esc opens the Menu and pauses"); await r.shot("05_menu_ship")
            await r.cmd("xp"); await r.cmd("tab_ship"); await pg.wait_for_timeout(500); await r.shot("06_ship_points")
            for t in ("journal", "map", "settings"):
                await r.cmd("tab_" + t); await pg.wait_for_timeout(700); s = await r.state(); r.check(s["tab"] == t, "page %s opens" % t); await r.shot("07_menu_" + t)
            await r.key("Escape", 500); s = await r.state(); r.check(not s["menu"] and not s["paused"], "Esc closes the Menu")
            # v0.3.4: fast travel from the Map page
            await r.cmd("all_cps"); await r.cmd("tab_map", 800); s = await r.state(); r.check(s["travel_btns"] >= 7, "the Map page lists reached checkpoints for fast travel (%d)" % s["travel_btns"]); await r.shot("07b_fast_travel")
            await r.key("Escape", 500)
            await r.cmd("travel_c_mouth"); s = await r.wait_for(lambda s: s["map"] == "cave" and s["phase"] == PLAY, 30, "fast travel to the cave mouth")
            r.check(s["cp"] == "c_mouth", "fast travel lands at the Cave mouth checkpoint (%s)" % s["cp"])
            await r.cmd("travel_m_glade"); s = await r.wait_for(lambda s: s["map"] == "meadow" and s["phase"] == PLAY, 30, "fast travel back to the glade")
            # touch controls show on touch and hide on a key (E5.4)
            cdp = await r.touch_drag(200, 520, 260, 500, 900); s = await r.state(); r.check(s["touch"], "touch controls show on a touch"); await r.shot("08_touch")
            await r.touch_end(cdp); await r.key("a", 400); s = await r.state(); r.check(not s["touch"], "touch controls hide on a key")
            # v0.3.4: left-handed layout and fixed sticks
            await r.cmd("set_touch_left", 300); cdp = await r.touch_drag(1000, 520, 1060, 520, 600); s = await r.state()
            r.check(s["touch_left"] and s["touch_move_x"] > 0.3, "Left-handed: the right thumb moves the ship (%.2f)" % s["touch_move_x"]); await r.shot("08b_touch_left"); await r.touch_end(cdp)
            await r.cmd("set_touch_left", 300); await r.cmd("set_touch_fixed", 300); cdp = await r.touch_drag(300, 400, 320, 400, 600); s = await r.state()
            r.check(s["touch_fixed"] and abs(s["move_o_x"] - 150.0) < 2.0, "Fixed sticks: the move stick stays in its spot (x %.0f)" % s["move_o_x"]); await r.touch_end(cdp)
            await r.cmd("set_touch_fixed", 300); await r.key("a", 400)
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
