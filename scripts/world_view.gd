extends Node2D
## Draws the world. All art is drawn in code. No textures.
## The map itself (floor, water, rifts and walls) is drawn once per map into chunks of 8 x 8 tiles. Godot keeps those
## drawings and moves them with the camera, so a frame only redraws the things that move. Off-screen chunks are culled.
## Layers, back to front: floor chunks (z -3), the under layer (z -2: water shimmer, gates, doors, checkpoints, finds),
## wall chunks (z -1), then this node (z 0: pickups, enemies, the ship, shots and sparks).

const Enemy := preload("res://scripts/enemy.gd")
const T := 64.0
const CH := 8

class Chunk extends Node2D:
	var v: Node2D
	var cx: int = 0
	var cy: int = 0
	var walls: bool = false
	func _draw() -> void:
		v.draw_chunk(self, cx, cy, walls)

class Under extends Node2D:
	var v: Node2D
	func _draw() -> void:
		v.draw_under(self)

var g: Node2D                                   # main.gd, set before it joins the tree
var floor_a: Color = Color.WHITE
var floor_b: Color = Color.WHITE
var wall_a: Color = Color.WHITE
var wall_b: Color = Color.WHITE
var wall_c: Color = Color.WHITE
var water_a: Color = Color.WHITE
var rift_a: Color = Color.WHITE
var theme: String = "meadow"
var font: Font
var under: Under
var floor_chunks: Array[Chunk] = []
var wall_chunks: Array[Chunk] = []
var water_tiles: Array[Vector2i] = []
var rift_tiles: Array[Vector2i] = []
var draw_ms: float = 0.0                        # smoothed time spent in the two per-frame draws, for the test state

func _ready() -> void:
	font = ThemeDB.fallback_font
	under = Under.new()
	under.v = self
	under.z_index = -2
	add_child(under)
	map_changed()

func redraw() -> void:
	queue_redraw()
	under.queue_redraw()

func map_changed() -> void:
	theme = str(g.map.get("theme", "meadow"))
	match theme:
		"meadow":
			floor_a = Color("8ed06a"); floor_b = Color("86c861")
			wall_a = Color("1f6a45"); wall_b = Color("2f8d58"); wall_c = Color("49ad6c")
			water_a = Color("4fb4ea"); rift_a = Color("1a2a3c")
		"cave":
			floor_a = Color("6f6c9f"); floor_b = Color("686596")
			wall_a = Color("24213f"); wall_b = Color("3a3663"); wall_c = Color("4c4780")
			water_a = Color("3f86c8"); rift_a = Color("0e0c1c")
		_:
			floor_a = Color("c2ad90"); floor_b = Color("b8a386")
			wall_a = Color("3e2f25"); wall_b = Color("6a5240"); wall_c = Color("86694f")
			water_a = Color("4fb4ea"); rift_a = Color("180e10")
	RenderingServer.set_default_clear_color(wall_a)
	if g.mw == 0:
		return
	water_tiles.clear()
	rift_tiles.clear()
	for ty: int in g.mh:
		for tx: int in g.mw:
			var k: int = g.tiles[ty * g.mw + tx]
			if k == 2:
				water_tiles.append(Vector2i(tx, ty))
			elif k == 3:
				rift_tiles.append(Vector2i(tx, ty))
	# chunk nodes are made once and reused for every map (E4.5)
	var cw: int = int(ceil(float(g.mw) / float(CH)))
	var chh: int = int(ceil(float(g.mh) / float(CH)))
	var need: int = cw * chh
	while floor_chunks.size() < need:
		floor_chunks.append(_make_chunk(false, -3))
		wall_chunks.append(_make_chunk(true, -1))
	for i: int in floor_chunks.size():
		var on: bool = i < need
		for c: Chunk in [floor_chunks[i], wall_chunks[i]]:
			c.visible = on
			if on:
				c.cx = i % cw
				c.cy = i / cw
				c.queue_redraw()

func _make_chunk(walls: bool, z: int) -> Chunk:
	var c := Chunk.new()
	c.v = self
	c.walls = walls
	c.z_index = z
	add_child(c)
	return c

func _hash(x: int, y: int) -> float:
	var n: int = (x * 374761393 + y * 668265263) & 0x7fffffff
	n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff
	return float(n % 1000) / 1000.0

func _view_rect(margin: float) -> Rect2:
	var vs: Vector2 = get_viewport_rect().size
	var c: Vector2 = g.cam.get_screen_center_position()
	return Rect2(c - vs * 0.5 - Vector2(margin, margin), vs + Vector2(margin, margin) * 2.0)

# ------------------------------------------------------------------ the map, drawn once per map

func draw_chunk(ci: CanvasItem, cx: int, cy: int, walls: bool) -> void:
	var x0: int = cx * CH
	var y0: int = cy * CH
	var x1: int = mini(g.mw - 1, x0 + CH - 1)
	var y1: int = mini(g.mh - 1, y0 + CH - 1)
	if walls:
		for ty: int in range(y0, y1 + 1):
			for tx: int in range(x0, x1 + 1):
				if g.tiles[ty * g.mw + tx] == 1:
					_wall(ci, tx, ty)
		return
	ci.draw_rect(Rect2(float(x0) * T, float(y0) * T, float(x1 - x0 + 1) * T, float(y1 - y0 + 1) * T), floor_a)
	for ty: int in range(y0, y1 + 1):
		for tx: int in range(x0, x1 + 1):
			var k: int = g.tiles[ty * g.mw + tx]
			var px: float = float(tx) * T
			var py: float = float(ty) * T
			if k == 0:
				if (tx + ty) % 2 == 0:
					ci.draw_rect(Rect2(px, py, T, T), floor_b)
				var h: float = _hash(tx, ty)
				if h < 0.16:
					_floor_bit(ci, px, py, h)
			elif k == 1:
				ci.draw_rect(Rect2(px, py, T, T), wall_a)
			elif k == 2:
				ci.draw_rect(Rect2(px, py, T, T), water_a)
				if g.tile_at(tx, ty - 1) != 2:
					ci.draw_rect(Rect2(px, py, T, 6.0), Color(1, 1, 1, 0.3))
			elif k == 3:
				ci.draw_rect(Rect2(px, py, T, T), rift_a)
				if g.tile_at(tx, ty - 1) != 3:
					ci.draw_rect(Rect2(px, py, T, 16.0), floor_a.darkened(0.45))
					ci.draw_rect(Rect2(px, py + 16.0, T, 10.0), floor_a.darkened(0.7))

func _floor_bit(ci: CanvasItem, px: float, py: float, h: float) -> void:
	var o := Vector2(px + 12.0 + h * 240.0, py + 14.0 + fmod(h * 977.0, 1.0) * 36.0)
	if theme == "meadow":
		if h < 0.05:
			ci.draw_circle(o, 5.0, Color("fff3a0"))
			ci.draw_circle(o, 2.0, Color("f2913d"))
		else:
			ci.draw_rect(Rect2(o.x, o.y, 3.0, 9.0), Color("5fae4a"))
			ci.draw_rect(Rect2(o.x + 6.0, o.y + 2.0, 3.0, 7.0), Color("5fae4a"))
	elif theme == "cave":
		ci.draw_circle(o, 4.0, Color("55527f"))
		if h < 0.04:
			ci.draw_circle(o + Vector2(10, 4), 3.0, Color("8ee6ff", 0.6))
	else:
		ci.draw_rect(Rect2(o.x, o.y, 14.0, 2.0), Color("a08a70"))

func _wall(ci: CanvasItem, tx: int, ty: int) -> void:
	var px: float = float(tx) * T
	var py: float = float(ty) * T
	var h: float = _hash(tx, ty)
	var below_open: bool = g.tile_at(tx, ty + 1) != 1
	if theme == "meadow":
		var c := Vector2(px + 32.0 + (h - 0.5) * 10.0, py + 30.0 + (fmod(h * 31.0, 1.0) - 0.5) * 10.0)
		ci.draw_circle(c + Vector2(0, 8), 40.0, wall_a)
		ci.draw_circle(c, 37.0, wall_b)
		ci.draw_circle(c + Vector2(-9, -11), 21.0, wall_c)
		if h > 0.8:
			ci.draw_circle(c + Vector2(12, 6), 5.0, Color("f06a6a"))
	elif theme == "cave":
		ci.draw_rect(Rect2(px, py, T, T), wall_b)
		ci.draw_rect(Rect2(px + 6.0, py + 5.0, T - 12.0, T - 16.0), wall_c)
		ci.draw_rect(Rect2(px + 12.0 + h * 20.0, py + 12.0, 14.0, 5.0), wall_c.lightened(0.15))
		if below_open:
			ci.draw_rect(Rect2(px, py + T - 12.0, T, 12.0), wall_a)
	else:
		ci.draw_rect(Rect2(px, py, T, T), wall_b)
		ci.draw_rect(Rect2(px + 2.0, py + 2.0, T - 4.0, 27.0), wall_c)
		var off: float = 0.0 if ty % 2 == 0 else 16.0
		ci.draw_rect(Rect2(px + 2.0, py + 33.0, 28.0 + off, 27.0), wall_c)
		ci.draw_rect(Rect2(px + 34.0 + off, py + 33.0, 28.0 - off, 27.0), wall_c)
		if below_open:
			ci.draw_rect(Rect2(px, py + T - 10.0, T, 10.0), wall_a)

# ------------------------------------------------------------------ the under layer, every frame

func draw_under(ci: CanvasItem) -> void:
	if g == null or g.mw == 0:
		return
	var t0: int = Time.get_ticks_usec()
	var vr: Rect2 = _view_rect(T)
	var t: float = g.time
	for wt: Vector2i in water_tiles:
		var px: float = float(wt.x) * T
		var py: float = float(wt.y) * T
		if not vr.has_point(Vector2(px, py)):
			continue
		var w: float = sin(t * 1.6 + float(wt.x) * 0.9 + float(wt.y) * 1.7) * 8.0
		ci.draw_rect(Rect2(px + 12.0 + w, py + 18.0, 22.0, 3.0), Color(1, 1, 1, 0.35))
		ci.draw_rect(Rect2(px + 30.0 - w, py + 42.0, 18.0, 3.0), Color(1, 1, 1, 0.25))
	for rt: Vector2i in rift_tiles:
		var rx: float = float(rt.x) * T
		var ry: float = float(rt.y) * T
		if not vr.has_point(Vector2(rx, ry)):
			continue
		var s: float = fmod(t * 0.35 + _hash(rt.x, rt.y), 1.0)
		ci.draw_circle(Vector2(rx + 14.0 + _hash(rt.y, rt.x) * 36.0, ry + T - s * T), 2.5, Color(0.6, 0.85, 1.0, 0.5 * (1.0 - s)))
	# breakables, the wagon and coin caches
	for pk: Variant in g.props.keys():
		var pt: Vector2i = pk
		var pc: Vector2 = g.tile_center(pt.x, pt.y)
		if vr.has_point(pc):
			_prop(ci, pc, g.props[pk], t)
	for oc: Dictionary in g.open_caches:
		var op: Vector2 = oc["pos"]
		if vr.has_point(op):
			_cache(ci, op, t)
	for gk: Variant in g.gates.keys():
		var gt: Vector2i = gk
		var gp := Vector2(float(gt.x) * T, float(gt.y) * T)
		if not vr.has_point(gp):
			continue
		if g.gate_closed(gt.x, gt.y):
			ci.draw_rect(Rect2(gp, Vector2(T, T)), Color("5b2a4a"))
			for i: int in 3:
				ci.draw_colored_polygon(PackedVector2Array([gp + Vector2(8.0 + float(i) * 18.0, T - 6.0), gp + Vector2(17.0 + float(i) * 18.0, 8.0), gp + Vector2(26.0 + float(i) * 18.0, T - 6.0)]), Color("d85fa3"))
		else:
			ci.draw_rect(Rect2(gp, Vector2(T, 5.0)), Color(0.35, 0.16, 0.3, 0.5))
			ci.draw_rect(Rect2(gp + Vector2(0, T - 5.0), Vector2(T, 5.0)), Color(0.35, 0.16, 0.3, 0.5))
	for d: Dictionary in g.doors:
		var dp: Vector2 = d["pos"]
		if not vr.has_point(dp):
			continue
		ci.draw_circle(dp, 30.0, Color(0.05, 0.05, 0.12))
		for i: int in 3:
			var a: float = t * 2.0 + float(i) * TAU / 3.0
			ci.draw_arc(dp, 12.0 + float(i) * 6.0, a, a + 2.2, 10, Color(0.6, 0.8, 1.0, 0.75), 3.0)
	for cp: Dictionary in g.checkpoints:
		var p: Vector2 = cp["pos"]
		if not vr.has_point(p):
			continue
		var on: bool = str(g.save["cp"]) == str(cp["id"])
		ci.draw_circle(p + Vector2(0, 14), 26.0, Color(0, 0, 0, 0.18))
		ci.draw_rect(Rect2(p.x - 18.0, p.y + 2.0, 36.0, 16.0), Color("e9e2d0"))
		ci.draw_rect(Rect2(p.x - 12.0, p.y - 6.0, 24.0, 10.0), Color("cfc6b0"))
		var bob: float = sin(t * 3.0) * 4.0
		var col: Color = Color("ffd84a") if on else Color("9fd8ff")
		var q: Vector2 = p + Vector2(0, -26.0 + bob)
		ci.draw_colored_polygon(PackedVector2Array([q + Vector2(0, -14), q + Vector2(11, 0), q + Vector2(0, 14), q + Vector2(-11, 0)]), col)
		ci.draw_colored_polygon(PackedVector2Array([q + Vector2(0, -8), q + Vector2(5, 0), q + Vector2(0, 4), q + Vector2(-5, 0)]), Color(1, 1, 1, 0.7))
		if on:
			ci.draw_arc(p + Vector2(0, 10), 30.0 + sin(t * 2.0) * 3.0, 0.0, TAU, 28, Color(1.0, 0.85, 0.3, 0.5), 2.0)
	for f: Dictionary in g.open_finds:
		var fp: Vector2 = f["pos"]
		if not vr.has_point(fp):
			continue
		var fb: float = sin(t * 2.6 + fp.x) * 5.0
		var kind: String = str(f["kind"])
		ci.draw_circle(fp + Vector2(0, 18), 14.0, Color(0, 0, 0, 0.18))
		var fq: Vector2 = fp + Vector2(0, fb - 4.0)
		ci.draw_circle(fq, 22.0 + sin(t * 4.0) * 2.0, Color(1, 1, 0.7, 0.22))
		if kind == "heart":
			_heart(ci, fq, 14.0, Color("ff5d7a"))
		elif kind == "ability":
			ci.draw_circle(fq, 14.0, Color("38d6f0"))
			ci.draw_circle(fq, 8.0, Color.WHITE)
			ci.draw_arc(fq, 19.0, t * 3.0, t * 3.0 + 4.0, 16, Color("b8f4ff"), 3.0)
		else:
			_star(ci, fq, 15.0, 7.0, t * 0.8, Color("ffe066"))
			_star(ci, fq, 8.0, 4.0, t * 0.8, Color.WHITE)
	_time(t0)

# ------------------------------------------------------------------ the top layer, every frame

func _draw() -> void:
	if g == null or g.mw == 0:
		return
	var t0: int = Time.get_ticks_usec()
	var t: float = g.time
	var vr: Rect2 = _view_rect(80.0)
	# pickups
	for i: int in g.MAX_PICKS:
		var kk: int = g.k_kind[i]
		if kk == 0:
			continue
		var kp: Vector2 = g.k_pos[i]
		if kk == 3:
			var bob: float = sin(t * 5.0 + float(i)) * 2.0
			var w: float = maxf(0.25, absf(cos(t * 4.0 + float(i) * 0.7)))
			var cpos: Vector2 = kp + Vector2(0, bob)
			draw_set_transform(cpos, 0.0, Vector2(w, 1.0))
			draw_circle(Vector2.ZERO, 8.0, Color("b07818"))
			draw_circle(Vector2.ZERO, 6.2, Color("ffc83a"))
			draw_rect(Rect2(-1.5, -4.0, 3.0, 8.0), Color("fff2b0"))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		elif kk == 1:
			draw_colored_polygon(PackedVector2Array([kp + Vector2(0, -8), kp + Vector2(6, 0), kp + Vector2(0, 8), kp + Vector2(-6, 0)]), Color("7df0c0"))
			draw_colored_polygon(PackedVector2Array([kp + Vector2(0, -4), kp + Vector2(3, 0), kp + Vector2(0, 2), kp + Vector2(-3, 0)]), Color.WHITE)
		else:
			_heart(self, kp, 9.0, Color("ff5d7a"))
	# enemies on screen
	for e: Enemy in g.enemies:
		if e.alive and vr.has_point(e.pos):
			_enemy(e, t)
			if e.bar_t > 0.0 and e != g.boss and e.hp < e.max_hp:
				_bar(e)
	# ship
	if g.phase != g.Phase.DEFEAT:
		_ship(t)
	# shots, up to the highest slot in use
	for i: int in g.b_hi:
		var bk: int = g.b_kind[i]
		if bk == 0:
			continue
		var bp: Vector2 = g.b_pos[i]
		var br: float = g.b_r[i]
		if bk == 1:
			var tail: Vector2 = bp - (g.b_vel[i] as Vector2) * 0.022
			draw_line(tail, bp, Color(0.23, 0.82, 0.91, 0.5), br * 1.3)
			draw_circle(bp, br + 3.0, Color("3ad0e8"))
			draw_circle(bp, br - 0.5, Color("fffbe0"))
		else:
			var vr2: float = br * 1.3       # drawn bigger than the hit size: easy to see and fair to dodge
			draw_circle(bp, vr2 + 3.0, Color("5a1040"))
			draw_circle(bp, vr2, Color("ff5fb0"))
			draw_circle(bp, vr2 * 0.45, Color.WHITE)
	# sparks
	for i: int in g.MAX_PARTS:
		var life: float = g.p_life[i]
		if life > 0.0:
			var a: float = life / g.p_max[i]
			var pc: Color = g.p_col[i]
			pc.a *= a
			draw_circle(g.p_pos[i], g.p_size[i] * (0.4 + 0.6 * a), pc)
	_time(t0)

func _time(t0: int) -> void:
	draw_ms = lerpf(draw_ms, float(Time.get_ticks_usec() - t0) / 1000.0, 0.1)

# ------------------------------------------------------------------ shapes

func _heart(ci: CanvasItem, p: Vector2, s: float, col: Color) -> void:
	ci.draw_circle(p + Vector2(-s * 0.45, -s * 0.25), s * 0.55, col)
	ci.draw_circle(p + Vector2(s * 0.45, -s * 0.25), s * 0.55, col)
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-s * 0.95, 0), p + Vector2(s * 0.95, 0), p + Vector2(0, s)]), col)

func _star(ci: CanvasItem, p: Vector2, r1: float, r2: float, rot: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i: int in 10:
		var r: float = r1 if i % 2 == 0 else r2
		pts.append(p + Vector2.from_angle(rot + TAU * float(i) / 10.0 - PI / 2.0) * r)
	ci.draw_colored_polygon(pts, col)

func _bar(e: Enemy) -> void:
	var w: float = e.r * 2.0 + 8.0
	var a: float = minf(1.0, e.bar_t)
	var o := Vector2(e.pos.x - w * 0.5, e.pos.y - e.r - 16.0)
	draw_rect(Rect2(o - Vector2(2, 2), Vector2(w + 4.0, 9.0)), Color(0.05, 0.08, 0.16, 0.85 * a))
	draw_rect(Rect2(o, Vector2(w * clampf(e.hp / e.max_hp, 0.0, 1.0), 5.0)), Color(1.0, 0.42, 0.42, a))

func _prop(ci: CanvasItem, c: Vector2, pr: Dictionary, t: float) -> void:
	var kind: String = str(pr["k"])
	var hurt: float = 0.0 if float(pr["max"]) <= 0.0 else 1.0 - float(pr["hp"]) / float(pr["max"])
	ci.draw_circle(c + Vector2(0, 14), 22.0, Color(0, 0, 0, 0.16))
	match kind:
		"bush":
			ci.draw_circle(c + Vector2(0, 4), 24.0, Color("3f8a3a"))
			ci.draw_circle(c, 21.0, Color("7cbf4f").lerp(Color("c8b860"), hurt * 0.6))
			ci.draw_circle(c + Vector2(-7, -8), 10.0, Color("a3d96b"))
			for bpos: Vector2 in [Vector2(9, -4), Vector2(-4, 8), Vector2(11, 9)]:
				ci.draw_circle(c + bpos, 3.5, Color("e2507a"))
		"crystal":
			var cols: Array[Color] = [Color("5fd6f0"), Color("a98af0"), Color("8ee6ff")]
			var shards: Array[Vector2] = [Vector2(-10, 8), Vector2(9, 9), Vector2(0, 2)]
			var tall: Array[float] = [26.0, 22.0, 34.0]
			for i: int in 3:
				var b: Vector2 = c + shards[i]
				var h: float = tall[i] * (1.0 - hurt * 0.35)
				ci.draw_colored_polygon(PackedVector2Array([b + Vector2(-7, 0), b + Vector2(0, -h), b + Vector2(7, 0), b + Vector2(0, 6)]), cols[i])
				ci.draw_line(b + Vector2(0, -h), b + Vector2(0, 4), Color(1, 1, 1, 0.5), 2.0)
		"pot":
			ci.draw_circle(c + Vector2(0, 4), 19.0, Color("8a4a2a"))
			ci.draw_circle(c + Vector2(0, 2), 17.0, Color("c9744a"))
			ci.draw_rect(Rect2(c.x - 11.0, c.y - 20.0, 22.0, 8.0), Color("8a4a2a"))
			ci.draw_rect(Rect2(c.x - 9.0, c.y - 18.0, 18.0, 4.0), Color("3a2418"))
			ci.draw_line(c + Vector2(-14, 4), c + Vector2(14, 4), Color("e8c08a"), 3.0)
		"stall":
			# Wren's Wagon: a little cart with a striped awning and Wren the shopkeeper
			ci.draw_rect(Rect2(c.x - 30.0, c.y - 6.0, 60.0, 30.0), Color("8a5a34"))
			ci.draw_rect(Rect2(c.x - 30.0, c.y - 6.0, 60.0, 6.0), Color("5e3a20"))
			ci.draw_circle(c + Vector2(-20, 26), 8.0, Color("3a2418"))
			ci.draw_circle(c + Vector2(20, 26), 8.0, Color("3a2418"))
			ci.draw_circle(c + Vector2(-20, 26), 3.0, Color("c9a060"))
			ci.draw_circle(c + Vector2(20, 26), 3.0, Color("c9a060"))
			var bob: float = sin(t * 3.0) * 1.5
			var wren: Vector2 = c + Vector2(0, -14 + bob)
			ci.draw_circle(wren, 11.0, Color("a8743c"))
			ci.draw_circle(wren + Vector2(0, 3), 7.0, Color("f0dcb0"))
			ci.draw_circle(wren + Vector2(-4, -3), 2.2, Color("20202c"))
			ci.draw_circle(wren + Vector2(4, -3), 2.2, Color("20202c"))
			ci.draw_colored_polygon(PackedVector2Array([wren + Vector2(-3, 1), wren + Vector2(3, 1), wren + Vector2(0, 6)]), Color("ffb347"))
			for i: int in 6:
				var col: Color = Color("e2504c") if i % 2 == 0 else Color("f7f3e6")
				ci.draw_rect(Rect2(c.x - 34.0 + float(i) * 11.4, c.y - 32.0, 11.4, 12.0), col)
			ci.draw_rect(Rect2(c.x - 34.0, c.y - 34.0, 68.0, 3.0), Color("5e3a20"))
			# a coin sign and a mat at the front where the shop opens
			ci.draw_circle(c + Vector2(26, 4), 7.0, Color("ffc83a"))
			ci.draw_rect(Rect2(c.x - 22.0, c.y + 40.0, 44.0, 14.0), Color(0.75, 0.35, 0.3, 0.55))

func _cache(ci: CanvasItem, p: Vector2, t: float) -> void:
	ci.draw_circle(p + Vector2(0, 10), 16.0, Color(0, 0, 0, 0.18))
	ci.draw_circle(p, 20.0 + sin(t * 4.0) * 2.0, Color(1.0, 0.85, 0.3, 0.2))
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-13, 10), p + Vector2(13, 10), p + Vector2(9, -6), p + Vector2(-9, -6)]), Color("8a5a34"))
	ci.draw_rect(Rect2(p.x - 6.0, p.y - 11.0, 12.0, 6.0), Color("5e3a20"))
	for cp: Vector2 in [Vector2(-6, -9), Vector2(5, -10), Vector2(0, -14)]:
		ci.draw_circle(p + cp, 5.0, Color("b07818"))
		ci.draw_circle(p + cp, 3.8, Color("ffc83a"))
	var gl: float = fmod(t * 0.8, 1.0)
	ci.draw_circle(p + Vector2(8, -16), 2.0 + gl * 2.0, Color(1, 1, 0.9, 1.0 - gl))

func _eyes(p: Vector2, look: Vector2, gap: float, size: float) -> void:
	for sgn: float in [-1.0, 1.0]:
		var ep: Vector2 = p + look.orthogonal() * gap * sgn + look * size
		draw_circle(ep, size, Color.WHITE)
		draw_circle(ep + look * size * 0.4, size * 0.5, Color("20202c"))

func _enemy(e: Enemy, t: float) -> void:
	var p: Vector2 = e.pos
	var look: Vector2 = (g.ppos - p).normalized()
	var col: Color = Color.WHITE if e.flash > 0.0 else e.color
	var dark: Color = e.color.darkened(0.5)
	draw_circle(p + Vector2(0, e.r * 0.7), e.r * 0.9, Color(0, 0, 0, 0.18))
	match e.kind:
		"drifter":
			var wob: float = sin(t * 4.0 + e.seed) * 2.0
			draw_circle(p, e.r + 3.0, dark)
			draw_circle(p, e.r + wob * 0.3, col)
			draw_circle(p + Vector2(-6, -8), 6.0, col.lightened(0.25))
			_eyes(p, look, 7.0, 5.0)
		"mite":
			var flap: float = sin(t * 30.0 + e.seed) * 5.0
			draw_circle(p + look.orthogonal() * 11.0 - look * 3.0, 6.0 + flap * 0.3, Color(1, 1, 1, 0.6))
			draw_circle(p - look.orthogonal() * 11.0 - look * 3.0, 6.0 - flap * 0.3, Color(1, 1, 1, 0.6))
			draw_circle(p, e.r + 2.0, dark)
			draw_circle(p, e.r - 1.0, col)
			_eyes(p, look, 4.0, 3.0)
		"spitter":
			draw_circle(p, e.r + 3.0, dark)
			draw_circle(p, e.r, col)
			draw_line(p + look * 6.0, p + look * (e.r + 10.0), dark, 12.0)
			draw_line(p + look * 6.0, p + look * (e.r + 8.0), col.lightened(0.2), 7.0)
			_eyes(p - look * 4.0, look, 8.0, 4.5)
		"spinner":
			for i: int in 8:
				var d: Vector2 = Vector2.from_angle(e.ang * 0.6 + TAU * float(i) / 8.0)
				draw_line(p + d * 10.0, p + d * (e.r + 9.0), dark, 8.0)
			draw_circle(p, e.r + 2.0, dark)
			draw_circle(p, e.r - 2.0, col)
			draw_circle(p, 9.0, Color.WHITE)
			draw_circle(p + look * 3.0, 5.0, Color("20202c"))
		"charger":
			var fwd: Vector2 = e.dir if e.state > 0 else look
			var side: Vector2 = fwd.orthogonal()
			var pull: float = 6.0 if e.state == 1 else 0.0
			var cp: Vector2 = p - fwd * pull
			draw_colored_polygon(PackedVector2Array([cp + fwd * (e.r + 12.0), cp + side * (e.r + 4.0) - fwd * e.r, cp - side * (e.r + 4.0) - fwd * e.r]), dark)
			draw_colored_polygon(PackedVector2Array([cp + fwd * (e.r + 5.0), cp + side * e.r - fwd * (e.r - 5.0), cp - side * e.r - fwd * (e.r - 5.0)]), col)
			draw_line(cp + side * 10.0 + fwd * 8.0, cp + side * 20.0 + fwd * 22.0, Color("fff3d0"), 5.0)
			draw_line(cp - side * 10.0 + fwd * 8.0, cp - side * 20.0 + fwd * 22.0, Color("fff3d0"), 5.0)
			_eyes(cp - fwd * 6.0, fwd, 7.0, 4.0)
		"lobber":
			draw_circle(p, e.r + 3.0, dark)
			draw_circle(p, e.r, col)
			for i: int in 3:
				var d2: Vector2 = look.rotated((float(i) - 1.0) * 0.5)
				draw_circle(p + d2 * (e.r + 2.0), 7.0, dark)
				draw_circle(p + d2 * (e.r + 2.0), 4.0, Color("fff3a0"))
			_eyes(p - look * 5.0, look, 8.0, 5.0)
		"warden":
			if e.dormant:
				col = e.color.darkened(0.35)
			var spikes: int = 14
			for i: int in spikes:
				var a: float = e.ang * (0.9 if not e.dormant else 0.0) + TAU * float(i) / float(spikes)
				var d3: Vector2 = Vector2.from_angle(a)
				draw_colored_polygon(PackedVector2Array([p + d3 * (e.r + 22.0), p + d3.rotated(0.2) * (e.r - 2.0), p + d3.rotated(-0.2) * (e.r - 2.0)]), Color("3c7a4a") if not e.phase2 else Color("c24a4a"))
			draw_circle(p, e.r + 4.0, dark)
			draw_circle(p, e.r, col)
			draw_circle(p + Vector2(-16, -20), 16.0, col.lightened(0.18))
			if e.dormant:
				draw_line(p + Vector2(-20, 0), p + Vector2(20, 0), Color("20202c"), 5.0)
			else:
				draw_circle(p, 22.0, Color.WHITE)
				draw_circle(p + look * 8.0, 11.0, Color("20202c"))
				draw_circle(p + look * 8.0 + Vector2(-3, -3), 3.5, Color.WHITE)

## The Swallow glider (v0.2.1): swept wings and a forked tail, drawn facing the ship's eased heading.
const GLIDER: Array[Vector2] = [Vector2(40, 0), Vector2(2, -10), Vector2(-26, -38), Vector2(-14, -8), Vector2(-36, -14), Vector2(-24, 0),
	Vector2(-36, 14), Vector2(-14, 8), Vector2(-26, 38), Vector2(2, 10)]
const GLIDER_K := 0.7

func _ship(t: float) -> void:
	var p: Vector2 = g.ppos
	if g.invuln > 0.0 and g.dash_t <= 0.0 and int(t * 20.0) % 2 == 0:
		return
	var fwd: Vector2 = Vector2.from_angle(g.ship_ang)
	var side: Vector2 = fwd.orthogonal()
	var to_world: Callable = func(v: Vector2) -> Vector2: return p + fwd * v.x * GLIDER_K + side * v.y * GLIDER_K
	draw_circle(p + Vector2(0, 16), 15.0, Color(0, 0, 0, 0.2))
	# thruster flame from the forked tail, longer when moving
	var flame: float = 8.0 + minf(18.0, g.pvel.length() * 0.045) + sin(t * 22.0) * 3.0
	var tail: Vector2 = to_world.call(Vector2(-22, 0))
	draw_colored_polygon(PackedVector2Array([tail + side * 6.5, tail - side * 6.5, tail - fwd * (flame + 9.0)]), Color("ffb347"))
	draw_colored_polygon(PackedVector2Array([tail + side * 3.4, tail - side * 3.4, tail - fwd * (flame * 0.65 + 5.0)]), Color("fff0a8"))
	# body and outline
	var pts := PackedVector2Array()
	for v: Vector2 in GLIDER:
		pts.append(to_world.call(v))
	draw_colored_polygon(pts, Color("f7f3e6") if g.hurt_flash <= 0.0 else Color("ff8a8a"))
	var ring := PackedVector2Array(pts)
	ring.append(pts[0])
	draw_polyline(ring, Color("1f3b63"), 2.4, true)
	# wing stripes and cockpit
	draw_line(to_world.call(Vector2(0, -7)), to_world.call(Vector2(-18, -29)), Color("38c6e8"), 2.5, true)
	draw_line(to_world.call(Vector2(0, 7)), to_world.call(Vector2(-18, 29)), Color("38c6e8"), 2.5, true)
	var cp: Vector2 = to_world.call(Vector2(14, 0))
	draw_circle(cp, 6.0, Color("1f3b63"))
	draw_circle(cp, 4.5, Color("38c6e8"))
	draw_circle(cp - side * 1.5 - fwd * 1.0, 1.6, Color.WHITE)
	if g.dash_t > 0.0:
		draw_arc(p, 27.0, 0.0, TAU, 20, Color(0.6, 0.95, 1.0, 0.8), 3.0)
	elif g.shield_ready and g.owns("shield"):
		draw_arc(p, 30.0, t * 2.0, t * 2.0 + TAU * 0.8, 24, Color(0.6, 0.92, 1.0, 0.5), 2.0)
