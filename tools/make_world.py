#!/usr/bin/env python3
# Builds data/world.json for Tiny Tailwind (G4.9: content as data). Run from the repo root: python3 tools/make_world.py
# Tiles: '#' wall, '.' floor, '~' water (blocks movers, shots pass), '^' rift (only a dash crosses it).
import json
class Map:
    def __init__(s, name, theme, music, w, h):
        s.d = {"name": name, "theme": theme, "music": music, "w": w, "h": h, "checkpoints": [], "doors": [], "finds": [], "enemies": [], "arenas": []}
        s.g = [["#"] * w for _ in range(h)]
    def fill(s, x0, y0, x1, y1, c="."):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1): s.g[y][x] = c
    def cp(s, i, x, y): s.d["checkpoints"].append({"id": i, "x": x, "y": y})
    def door(s, x, y, to, tx, ty): s.fill(x, y, x, y); s.d["doors"].append({"x": x, "y": y, "to": to, "tx": tx, "ty": ty})
    def find(s, i, x, y): assert s.g[y][x] == ".", (i, x, y); s.d["finds"].append({"id": i, "x": x, "y": y})
    def en(s, kind, pts, g=""):
        for x, y in pts:
            assert s.g[y][x] == ".", (kind, x, y); s.d["enemies"].append({"k": kind, "x": x, "y": y, "g": g})
    def arena(s, i, rect, gates):
        for x, y in gates: assert s.g[y][x] == ".", (i, x, y)
        s.d["arenas"].append({"id": i, "rect": rect, "gates": gates})
    def out(s):
        for r in (s.g[0], s.g[-1]): assert set(r) == {"#"}
        s.d["rows"] = ["".join(r) for r in s.g]; return s.d

# ---- Sunmeadow: the overworld -------------------------------------------------------------
m = Map("Sunmeadow", "meadow", "meadow", 56, 36)
m.fill(4, 14, 13, 21)                      # start glade
m.fill(3, 22, 4, 24)                       # hidden nook under the glade
m.fill(8, 8, 9, 13); m.fill(4, 3, 16, 8)   # north grove
m.fill(17, 4, 19, 5); m.fill(17, 4, 18, 5, "^")   # dash shortcut to the north field
m.fill(14, 17, 22, 18); m.fill(22, 13, 30, 22)    # crossroads
m.fill(31, 13, 33, 14)
m.fill(25, 7, 26, 12); m.fill(20, 2, 34, 6); m.fill(35, 3, 36, 5)   # north field and cave porch
m.fill(25, 23, 26, 26); m.fill(16, 27, 36, 33); m.fill(21, 29, 29, 31, "~")   # south ruins and lake
m.fill(8, 30, 15, 31); m.fill(3, 26, 7, 33)       # south-west hollow
m.fill(37, 30, 38, 31); m.fill(39, 28, 52, 33); m.fill(44, 30, 47, 31, "~")   # south-east pond
m.fill(31, 17, 37, 18); m.fill(38, 10, 42, 26)    # east bank
m.fill(43, 10, 44, 26, "^")                       # the Rift
m.fill(45, 10, 52, 26)                            # far bank
m.fill(48, 8, 49, 9); m.fill(46, 3, 52, 7)        # north-east nook
m.cp("m_glade", 8, 17); m.cp("m_cross", 26, 17); m.cp("m_bank", 40, 18); m.cp("m_far", 48, 18)
m.door(37, 4, "cave", 3, 12); m.door(53, 18, "dungeon", 3, 17)
for i, (x, y) in enumerate([(5, 4), (3, 24), (33, 13), (30, 32), (4, 27), (51, 32), (47, 12), (51, 4), (21, 3)]): m.find("m%d" % (i + 1), x, y)
m.en("drifter", [(12, 5), (14, 7), (6, 7), (18, 18), (24, 15), (28, 20), (22, 4), (30, 3)])
m.en("mite", [(27, 14), (28, 15), (29, 14), (18, 28), (19, 29), (17, 30), (10, 30), (11, 31), (5, 30), (6, 31), (41, 30), (42, 31)])
m.en("spitter", [(32, 5), (28, 4), (34, 28), (18, 32), (5, 28), (40, 12), (41, 24), (50, 29)])
m.en("charger", [(40, 15), (40, 22), (48, 30), (33, 31)])
m.en("spinner", [(47, 22), (50, 14)])
m.en("lobber", [(49, 5), (51, 20)])

# ---- Echo Hollow: the cave -----------------------------------------------------------------
c = Map("Echo Hollow", "cave", "deep", 34, 24)
c.fill(2, 10, 6, 14); c.fill(7, 11, 11, 13)
c.fill(12, 7, 19, 16)                              # chamber A
c.fill(15, 5, 16, 6); c.fill(9, 1, 23, 4)          # chamber B
c.fill(20, 11, 23, 12); c.fill(24, 8, 31, 15)      # chamber C, home of the Dash Core
c.fill(27, 16, 28, 18); c.fill(20, 19, 32, 22); c.fill(24, 19, 25, 22, "^")   # chamber D with a rift
c.fill(14, 17, 15, 18); c.fill(8, 19, 17, 22); c.fill(9, 21, 10, 22, "~")     # chamber E
c.cp("c_mouth", 4, 12); c.cp("c_core", 21, 11)
c.door(1, 12, "meadow", 35, 4)
for i, (x, y) in [("c1", (13, 8)), ("c2", (10, 2)), ("c_dash", (29, 11)), ("c4", (21, 20)), ("c5", (12, 20))]: c.find(i, x, y)
c.en("mite", [(13, 10), (14, 14), (18, 9), (18, 15), (12, 3), (13, 2), (20, 2), (21, 3)])
c.en("spitter", [(17, 12), (22, 2), (16, 20), (30, 20)])
c.en("spinner", [(16, 3), (28, 9), (30, 14)])
c.en("drifter", [(26, 13), (27, 10), (11, 20), (29, 21)])
c.en("charger", [(31, 21)])

# ---- Thornkeep: the dungeon ----------------------------------------------------------------
d = Map("Thornkeep", "keep", "deep", 52, 34)
d.fill(2, 14, 7, 20); d.fill(8, 16, 11, 18)
d.fill(12, 11, 22, 23)                             # arena 1
d.fill(23, 16, 27, 18); d.fill(25, 16, 26, 18, "^")
d.fill(28, 13, 34, 21)                             # hub
d.fill(30, 8, 32, 12); d.fill(26, 2, 36, 7)        # north room
d.fill(30, 22, 32, 25); d.fill(24, 26, 38, 32)     # arena 2
d.fill(35, 16, 37, 18); d.fill(38, 9, 50, 25)      # boss hall
d.cp("d_gate", 4, 17); d.cp("d_hub", 31, 17)
d.door(1, 17, "meadow", 51, 18)
for i, (x, y) in [("d1", (35, 3)), ("d2", (27, 3)), ("d3", (37, 31)), ("d4", (25, 31)), ("d5", (49, 10)), ("d6", (49, 24))]: d.find(i, x, y)
d.en("spitter", [(14, 13), (20, 21)], "d_a1"); d.en("charger", [(20, 13), (14, 21)], "d_a1"); d.en("mite", [(17, 15), (17, 19), (15, 17), (19, 17)], "d_a1")
d.arena("d_a1", [13, 12, 21, 22], [[11, 16], [11, 17], [11, 18], [23, 16], [23, 17], [23, 18]])
d.en("spinner", [(31, 4)]); d.en("lobber", [(28, 5), (34, 5)]); d.en("drifter", [(31, 10), (30, 6), (33, 3)])
d.en("spinner", [(31, 29)], "d_a2"); d.en("lobber", [(26, 28), (36, 28)], "d_a2"); d.en("charger", [(27, 31), (35, 31)], "d_a2"); d.en("mite", [(29, 27), (33, 27), (29, 31), (33, 31)], "d_a2")
d.arena("d_a2", [25, 27, 37, 31], [[30, 25], [31, 25], [32, 25]])
d.en("warden", [(45, 17)], "d_boss")
d.arena("d_boss", [39, 10, 49, 24], [[37, 16], [37, 17], [37, 18]])

json.dump({"tile": 64, "start": {"map": "meadow", "x": 7, "y": 19}, "maps": {"meadow": m.out(), "cave": c.out(), "dungeon": d.out()}}, open("data/world.json", "w"), indent=0)
n = sum(len(x.d["finds"]) for x in (m, c, d)); print("world done: finds", n, "enemies", [len(x.d["enemies"]) for x in (m, c, d)])
for x in (m, c, d): print("\n".join(x.d["rows"])); print()
