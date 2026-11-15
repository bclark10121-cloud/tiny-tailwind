extends RefCounted
## Headless test bot (G7.1 override 5, G7.2). Never runs for players: only with the command line switches --bot or --reach.
##   godot --headless --path . -- --reach    proves every find is reachable and the dash gate holds
##   godot --headless --path . -- --bot      plays the whole beta route: finds, cave, dash, keep and the warden

const Enemy := preload("res://scripts/enemy.gd")
const LIMIT := 60 * 60 * 14        # 45 minutes of game time

var g: Node2D
var move: Vector2 = Vector2.ZERO
var aim: Vector2 = Vector2.RIGHT
var fire: bool = false
var dash: bool = false
var finished: bool = false
var ok: bool = false
var ticks: int = 0
var path: Array[Vector2i] = []
var goal_name: String = ""
var replan: int = 0
var seen_end: bool = false
var touched: Dictionary = {}
var last_pos: Vector2 = Vector2.ZERO
var still: int = 0
var last_phase: int = -1
var spend_i: int = 0
var assist_note: String = ""
var log_t: int = 0
var shop_visits: int = 0
var bought_log: Array[String] = []
var last_tgt: Enemy = null
var last_tgt_pos: Vector2 = Vector2.ZERO

func begin() -> void:
	g.save["difficulty"] = 1 if OS.get_cmdline_user_args().has("--normal") else 0
	print("BOT start: %s difficulty, no other assist" % g.DIFF_NAMES[int(g.save["difficulty"])])

func spend_points() -> void:
	for n: int in 8:
		if int(g.save["points"]) <= 0:
			return
		g.spend_point(g.STATS[spend_i % 4])
		spend_i += 1

# ------------------------------------------------------------------ reach report

func _walk(dash_ok: bool, props_block: bool = false) -> Dictionary:
	var maps: Dictionary = g.world["maps"]
	var walls: Dictionary = {}
	if props_block:
		for mid: Variant in maps.keys():
			for pr: Variant in ((maps[mid] as Dictionary).get("props", []) as Array):
				walls["%s:%d,%d" % [str(mid), int((pr as Dictionary)["x"]), int((pr as Dictionary)["y"])]] = true
	var seen: Dictionary = {}
	var start: Dictionary = g.world["start"]
	var queue: Array = [[str(start["map"]), int(start["x"]), int(start["y"])]]
	seen["%s:%d,%d" % [str(start["map"]), int(start["x"]), int(start["y"])]] = true
	while not queue.is_empty():
		var cur: Array = queue.pop_back()
		var m: Dictionary = maps[cur[0]]
		var rows: Array = m["rows"]
		for d: Variant in (m["doors"] as Array):
			var dd: Dictionary = d
			if int(dd["x"]) == int(cur[1]) and int(dd["y"]) == int(cur[2]):
				var k: String = "%s:%d,%d" % [str(dd["to"]), int(dd["tx"]), int(dd["ty"])]
				if not seen.has(k):
					seen[k] = true
					queue.append([str(dd["to"]), int(dd["tx"]), int(dd["ty"])])
		for o: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var x: int = int(cur[1]) + o.x
			var y: int = int(cur[2]) + o.y
			if x < 0 or y < 0 or x >= int(m["w"]) or y >= int(m["h"]):
				continue
			var ch: String = (rows[y] as String)[x]
			if ch == "." or (dash_ok and ch == "^"):
				var k2: String = "%s:%d,%d" % [str(cur[0]), x, y]
				if not seen.has(k2) and not walls.has(k2):
					seen[k2] = true
					queue.append([cur[0], x, y])
	return seen

func reach_report() -> bool:
	var maps: Dictionary = g.world["maps"]
	var walk: Dictionary = _walk(false)
	var fly: Dictionary = _walk(true)
	var good: bool = true
	var n: int = 0
	var total: int = 0
	for mid: Variant in maps.keys():
		var m: Dictionary = maps[mid]
		for f: Variant in (m["finds"] as Array):
			var fd: Dictionary = f
			total += 1
			var k: String = "%s:%d,%d" % [str(mid), int(fd["x"]), int(fd["y"])]
			var name: String = str((g.find_by_id[str(fd["id"])] as Dictionary)["name"])
			if fly.has(k):
				n += 1
				print("REACH ok   %-8s %-20s %s" % [str(fd["id"]), name, "on foot" if walk.has(k) else "needs the dash"])
			else:
				good = false
				print("REACH FAIL %-8s %-20s not reachable" % [str(fd["id"]), name])
		for c: Variant in (m["checkpoints"] as Array):
			var cd: Dictionary = c
			if not fly.has("%s:%d,%d" % [str(mid), int(cd["x"]), int(cd["y"]) + 1]):
				good = false
				print("REACH FAIL checkpoint %s" % str(cd["id"]))
	if not walk.has("cave:29,11"):
		good = false
		print("REACH FAIL the Dash Core needs the dash")
	if walk.has("dungeon:3,17"):
		good = false
		print("REACH FAIL the keep is reachable without the dash")
	if not fly.has("dungeon:45,17"):
		good = false
		print("REACH FAIL the warden is not reachable")
	# coin caches, and props never block the only way to anything (they can be shot, but the route must not need it)
	var pwalk: Dictionary = _walk(true, true)
	var pfoot: Dictionary = _walk(false, true)
	var ncache: int = 0
	var cache_total: int = 0
	var cache_coins: int = 0
	for mid: Variant in maps.keys():
		var m2: Dictionary = maps[mid]
		for ca: Variant in (m2.get("caches", []) as Array):
			var cd: Dictionary = ca
			cache_total += 1
			cache_coins += int(cd["v"])
			var ck: String = "%s:%d,%d" % [str(mid), int(cd["x"]), int(cd["y"])]
			if pwalk.has(ck):
				ncache += 1
				print("REACH ok   %-8s coin cache, %2d coins  %s" % [str(cd["id"]), int(cd["v"]), "on foot" if walk.has(ck) else "needs the dash"])
			else:
				good = false
				print("REACH FAIL %-8s coin cache not reachable" % str(cd["id"]))
		var spots: Array = []
		for f: Variant in (m2["finds"] as Array):
			spots.append(["find " + str((f as Dictionary)["id"]), int((f as Dictionary)["x"]), int((f as Dictionary)["y"])])
		for c: Variant in (m2["checkpoints"] as Array):
			spots.append(["checkpoint " + str((c as Dictionary)["id"]), int((c as Dictionary)["x"]), int((c as Dictionary)["y"]) + 1])
		for d: Variant in (m2["doors"] as Array):
			spots.append(["door", int((d as Dictionary)["x"]), int((d as Dictionary)["y"])])
		for e: Variant in (m2["enemies"] as Array):
			if str((e as Dictionary)["k"]) == "warden":
				spots.append(["the warden", int((e as Dictionary)["x"]), int((e as Dictionary)["y"])])
		for sp: Array in spots:
			var sk: String = "%s:%d,%d" % [str(mid), int(sp[1]), int(sp[2])]
			if fly.has(sk) and not pwalk.has(sk):
				good = false
				print("REACH FAIL a breakable blocks the only way to %s on %s" % [str(sp[0]), str(mid)])
	var shop_ok: bool = false
	var mm: Dictionary = maps["meadow"]
	if mm.has("shop"):
		var shd: Dictionary = mm["shop"]
		shop_ok = pfoot.has("meadow:%d,%d" % [int(shd["x"]), int(shd["y"]) + 1])
	if not shop_ok:
		good = false
		print("REACH FAIL Wren's Wagon is not reachable on foot from the start")
	if cache_total != g.cache_ids.size():
		good = false
	print("REACH caches %d/%d (%d coins). Breakables block nothing. Shop on foot: %s" % [ncache, cache_total, cache_coins, shop_ok])
	if total != g.find_defs.size():
		good = false
		print("REACH FAIL %d finds placed, %d defined" % [total, g.find_defs.size()])
	print("REACH %s %d/%d finds. Dash Core on foot: %s. Keep gated by the dash: %s" % ["ok" if good else "FAIL", n, total, walk.has("cave:29,11"), not walk.has("dungeon:3,17")])
	return good

# ------------------------------------------------------------------ play

func _tile(p: Vector2) -> Vector2i:
	return Vector2i(int(floor(p.x / 64.0)), int(floor(p.y / 64.0)))

## Cheapest paths from the ship over the current map. Rift tiles cost a lot, so a path crosses a rift the short way.
func _costs(from: Vector2i) -> Dictionary:
	var cost: Dictionary = {from: 0}
	var prev: Dictionary = {}
	var queue: Array[Vector2i] = [from]
	var head: int = 0
	var dash_ok: bool = g.has_dash()
	while head < queue.size():
		var cur: Vector2i = queue[head]
		head += 1
		var cc: int = cost[cur]
		for o: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx: Vector2i = cur + o
			var k: int = g.tile_at(nx.x, nx.y)
			if k == 1 or k == 2 or (k == 3 and not dash_ok) or g.gate_closed(nx.x, nx.y) or g.props.has(nx):
				continue
			var nc: int = cc + (60 if k == 3 else 1)
			if not cost.has(nx) or nc < int(cost[nx]):
				cost[nx] = nc
				prev[nx] = cur
				queue.append(nx)
	return {"cost": cost, "prev": prev}

func _plan() -> void:
	path.clear()
	goal_name = ""
	var from: Vector2i = _tile(g.ppos)
	var res: Dictionary = _costs(from)
	var cost: Dictionary = res["cost"]
	var best: Vector2i = Vector2i(-1, -1)
	var bc: int = 1 << 30
	for f: Dictionary in g.open_finds:
		var t: Vector2i = _tile(f["pos"])
		if cost.has(t) and int(cost[t]) < bc:
			bc = int(cost[t])
			best = t
			goal_name = "find " + str(f["id"])
	for oc: Dictionary in g.open_caches:
		var t3: Vector2i = _tile(oc["pos"])
		if cost.has(t3) and int(cost[t3]) < bc:
			bc = int(cost[t3])
			best = t3
			goal_name = "cache " + str(oc["id"])
	if g.shop_pos != Vector2.INF and g.shop_armed and shop_visits < 2 and int(g.save["coins"]) >= 80:
		var t4: Vector2i = _tile(g.shop_pos)
		if cost.has(t4):
			bc = -1
			best = t4
			goal_name = "Wren's Wagon"
	for c: Dictionary in g.checkpoints:
		if touched.has(str(c["id"])):
			continue
		var t2: Vector2i = _tile(c["pos"])
		if cost.has(t2) and int(cost[t2]) < bc:
			bc = int(cost[t2])
			best = t2
			goal_name = "checkpoint " + str(c["id"])
	if best.x < 0:
		var want: String = ""
		if g.map_id == "meadow":
			want = "dungeon" if g.has_dash() and not (g.has_flag("d_boss") and _map_done("dungeon")) else "cave"
			if g.has_dash() and _map_done("cave") and _map_done("dungeon") and g.has_flag("d_boss"):
				want = ""
			elif g.has_dash() and not _map_done("cave"):
				want = "cave"
		elif g.map_id == "cave":
			want = "meadow"
		elif g.map_id == "dungeon":
			if not g.has_flag("d_boss") and g.boss != null:
				best = _tile(g.boss.home) + Vector2i(-4, 0)
				goal_name = "the warden"
			else:
				want = "meadow"
		for d: Dictionary in g.doors:
			if str(d["to"]) == want:
				best = Vector2i(int(d["tx"]), int(d["ty"]))
				goal_name = "door to " + want
	if best.x < 0 or not cost.has(best):
		return
	var prev: Dictionary = res["prev"]
	var cur: Vector2i = best
	while cur != from:
		path.push_front(cur)
		cur = prev[cur]

func _map_done(mid: String) -> bool:
	var m: Dictionary = (g.world["maps"] as Dictionary)[mid]
	for f: Variant in (m["finds"] as Array):
		if not g.has_find(str((f as Dictionary)["id"])):
			return false
	for ca: Variant in (m.get("caches", []) as Array):
		if not (g.save["caches"] as Array).has(str((ca as Dictionary)["id"])):
			return false
	return true

func _all_done() -> bool:
	return g.has_flag("d_boss") and (g.save["finds"] as Array).size() == g.find_defs.size() and (g.save["caches"] as Array).size() == g.cache_ids.size() and shop_visits >= 1

func think() -> void:
	move = Vector2.ZERO
	fire = false
	dash = false
	ticks += 1
	if ticks > LIMIT:
		_finish(false, "ran out of time")
		return
	var ph: int = g.phase
	if ph != last_phase:
		last_phase = ph
		path.clear()
		replan = 0
	if ph == g.Phase.TITLE:
		g.hud.hide_title()
		g.start_game()
		return
	if ph == g.Phase.END:
		seen_end = true
		g.hud.close_end()
		return
	if g.hud.shop_open:
		shop_visits += 1
		for id: String in ["heart", "shield", "magnet", "quick_dash", "point", "treasure_map"]:
			while g.buy(id):
				bought_log.append(id)
		print("BOT shop visit %d: bought %s, %d coins left" % [shop_visits, str(bought_log), int(g.save["coins"])])
		g.hud.close_shop()
		path.clear()
		return
	if ph != g.Phase.PLAY:
		return
	if int(g.save["defeats"]) >= 12 and not bool(g.save["invincible"]):
		g.save["invincible"] = true
		assist_note = " Invincible assist switched on after 12 defeats."
		print("BOT note: 12 defeats, switching the Invincible assist on")
	for c: Dictionary in g.checkpoints:
		if (c["pos"] as Vector2).distance_squared_to(g.ppos) < 60.0 * 60.0:
			touched[str(c["id"])] = true
	log_t -= 1
	if log_t <= 0:
		log_t = 60 * 30
		var dbg: String = ""
		for e: Enemy in g.enemies:
			if e.alive and e.group == g.active_arena and g.active_arena != "":
				dbg += " %s@%d,%d aw=%s" % [e.kind, int(e.pos.x / 64.0), int(e.pos.y / 64.0), e.awake]
		print("BOT t=%ds map=%s goal=%s finds=%d lv=%d hp=%d defeats=%d at=%s arena=%s%s" % [ticks / 60, g.map_id, goal_name, (g.save["finds"] as Array).size(), int(g.save["level"]), g.hp, int(g.save["defeats"]), str(_tile(g.ppos)), g.active_arena, dbg])

	# aim at the nearest enemy in range with a clear line
	var tgt: Enemy = g.nearest_enemy(g.shot_range())
	if tgt != null and g._clear_line(g.ppos, tgt.pos):
		var tv: Vector2 = (tgt.pos - last_tgt_pos) * 60.0 if tgt == last_tgt else Vector2.ZERO
		var lead: Vector2 = tgt.pos + tv * (tgt.pos.distance_to(g.ppos) / 780.0) - g.pvel * 0.15 * (tgt.pos.distance_to(g.ppos) / 780.0)
		aim = (lead - g.ppos).normalized()
		fire = true
	last_tgt = tgt
	if tgt != null:
		last_tgt_pos = tgt.pos

	# step away from shots that are close
	var dodge: Vector2 = Vector2.ZERO
	for i: int in g.MAX_BULLETS:
		if g.b_kind[i] == 2:
			var off: Vector2 = g.ppos - g.b_pos[i]
			var d2: float = off.length_squared()
			if d2 < 130.0 * 130.0 and d2 > 1.0 and off.dot(g.b_vel[i]) > 0.0:
				var side: Vector2 = (g.b_vel[i] as Vector2).orthogonal().normalized()
				if side.dot(off) < 0.0:
					side = -side
				dodge += side * (1.0 - sqrt(d2) / 130.0)

	if g.active_arena != "":
		var foe: Enemy = g.nearest_enemy(4000.0)
		if foe != null:
			var to: Vector2 = foe.pos - g.ppos
			var d: float = to.length()
			var want: float = 300.0 if foe == g.boss else 230.0
			var radial: float = 1.0 if d > want + 40.0 else (-1.0 if d < want - 40.0 else 0.0)
			move = (to.normalized() * radial + to.normalized().orthogonal() * 0.9 + dodge * 2.0).limit_length(1.0)
		return

	if _all_done() and seen_end:
		_finish(true, "")
		return
	replan -= 1
	if path.is_empty() or replan <= 0:
		_plan()
		replan = 90
		if path.is_empty():
			if _all_done():
				if g.end_t < 0.0:
					_finish(true, "")
				return
			still += 90
			if still > 60 * 20:
				_finish(false, "no goal is reachable on %s" % g.map_id)
			return
	var pt: Vector2i = _tile(g.ppos)
	while not path.is_empty() and path[0] == pt:
		path.pop_front()
	if path.is_empty():
		return
	var nxt: Vector2i = path[0]
	if g.tile_at(nxt.x, nxt.y) == 3 or g.tile_at(pt.x, pt.y) == 3:
		var j: int = 0
		while j < path.size() - 1 and g.tile_at(path[j].x, path[j].y) == 3:
			j += 1
		var land: Vector2 = g.tile_center(path[j].x, path[j].y)
		var dirn: Vector2 = (land - g.ppos).normalized()
		if g.dash_t > 0.0 or g.tile_at(pt.x, pt.y) == 3:
			move = dirn
		elif g.dash_cd <= 0.0:
			var here: Vector2 = g.tile_center(pt.x, pt.y)
			if here.distance_squared_to(g.ppos) > 14.0 * 14.0:
				move = (here - g.ppos).normalized()      # line up on the tile centre first
			else:
				move = dirn
				dash = true
		return
	move = ((g.tile_center(nxt.x, nxt.y) - g.ppos).normalized() + dodge * 0.9).limit_length(1.0)
	if g.ppos.distance_squared_to(last_pos) < 4.0:
		still += 1
		if still > 60 * 25:
			_finish(false, "stuck at %s on %s heading for %s" % [str(pt), g.map_id, goal_name])
	else:
		still = 0
		last_pos = g.ppos

func _finish(good: bool, why: String) -> void:
	finished = true
	ok = good and _all_done()
	var n: int = (g.save["finds"] as Array).size()
	print("BOT %s: warden calmed %s, finds %d/%d, caches %d/%d, coins earned %d, shop visits %d, bought %s, level %d, defeats %d, %d s of play.%s %s" % ["done" if ok else "FAIL", g.has_flag("d_boss"), n, g.find_defs.size(),
		(g.save["caches"] as Array).size(), g.cache_ids.size(), g.coins_earned, shop_visits, str(bought_log), int(g.save["level"]), int(g.save["defeats"]), ticks / 60, assist_note, why])
