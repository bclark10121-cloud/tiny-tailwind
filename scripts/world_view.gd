extends Node2D
## Draws the world: tiles, things, enemies, shots and the ship. All art is drawn in code. No textures.
## It only draws what the camera shows.

const Enemy := preload("res://scripts/enemy.gd")
const T := 64.0

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

func _ready() -> void:
	font = ThemeDB.fallback_font
	map_changed()

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

func _hash(x: int, y: int) -> float:
	var n: int = (x * 374761393 + y * 668265263) & 0x7fffffff
	n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff
	return float(n % 1000) / 1000.0

func _draw() -> void:
	if g == null or g.mw == 0:
		return
	var vs: Vector2 = get_viewport_rect().size
	var c: Vector2 = g.cam.get_screen_center_position()
	var x0: int = maxi(0, int(floor((c.x - vs.x * 0.5) / T)) - 1)
	var x1: int = mini(g.mw - 1, int(floor((c.x + vs.x * 0.5) / T)) + 1)
	var y0: int = maxi(0, int(floor((c.y - vs.y * 0.5) / T)) - 1)
	var y1: int = mini(g.mh - 1, int(floor((c.y + vs.y * 0.5) / T)) + 1)
	var t: float = g.time
	draw_rect(Rect2(c - vs, vs * 2.0), wall_a)
	draw_rect(Rect2(float(x0) * T, float(y0) * T, float(x1 - x0 + 1) * T, float(y1 - y0 + 1) * T), floor_a)
	# floor pattern, water and rifts
	for ty: int in range(y0, y1 + 1):
		for tx: int in range(x0, x1 + 1):
			var k: int = g.tiles[ty * g.mw + tx]
			var px: float = float(tx) * T
			var py: float = float(ty) * T
			if k == 0:
				if (tx + ty) % 2 == 0:
					draw_rect(Rect2(px, py, T, T), floor_b)
				var h: float = _hash(tx, ty)
				if h < 0.16:
					_floor_bit(px, py, h)
			elif k == 2:
				draw_rect(Rect2(px, py, T, T), water_a)
				var w: float = sin(t * 1.6 + float(tx) * 0.9 + float(ty) * 1.7) * 8.0
				draw_rect(Rect2(px + 12.0 + w, py + 18.0, 22.0, 3.0), Color(1, 1, 1, 0.35))
				draw_rect(Rect2(px + 30.0 - w, py + 42.0, 18.0, 3.0), Color(1, 1, 1, 0.25))
				if g.tile_at(tx, ty - 1) != 2:
					draw_rect(Rect2(px, py, T, 6.0), Color(1, 1, 1, 0.3))
			elif k == 3:
				draw_rect(Rect2(px, py, T, T), rift_a)
				if g.tile_at(tx, ty - 1) != 3:
					draw_rect(Rect2(px, py, T, 16.0), floor_a.darkened(0.45))
					draw_rect(Rect2(px, py + 16.0, T, 10.0), floor_a.darkened(0.7))
				var s: float = fmod(t * 0.35 + _hash(tx, ty), 1.0)
				draw_circle(Vector2(px + 14.0 + _hash(ty, tx) * 36.0, py + T - s * T), 2.5, Color(0.6, 0.85, 1.0, 0.5 * (1.0 - s)))
	# gates
	for gk: Variant in g.gates.keys():
		var gt: Vector2i = gk
		if gt.x < x0 or gt.x > x1 or gt.y < y0 or gt.y > y1:
			continue
		var gp := Vector2(float(gt.x) * T, float(gt.y) * T)
		if g.gate_closed(gt.x, gt.y):
			draw_rect(Rect2(gp, Vector2(T, T)), Color("5b2a4a"))
			for i: int in 3:
				draw_colored_polygon(PackedVector2Array([gp + Vector2(8.0 + float(i) * 18.0, T - 6.0), gp + Vector2(17.0 + float(i) * 18.0, 8.0), gp + Vector2(26.0 + float(i) * 18.0, T - 6.0)]), Color("d85fa3"))
		else:
			draw_rect(Rect2(gp + Vector2(0, 0), Vector2(T, 5.0)), Color(0.35, 0.16, 0.3, 0.5))
			draw_rect(Rect2(gp + Vector2(0, T - 5.0), Vector2(T, 5.0)), Color(0.35, 0.16, 0.3, 0.5))
	# doors, checkpoints, finds
	for d: Dictionary in g.doors:
		var dp: Vector2 = d["pos"]
		draw_circle(dp, 30.0, Color(0.05, 0.05, 0.12))
		for i: int in 3:
			var a: float = t * 2.0 + float(i) * TAU / 3.0
			draw_arc(dp, 12.0 + float(i) * 6.0, a, a + 2.2, 10, Color(0.6, 0.8, 1.0, 0.75), 3.0)
	for cp: Dictionary in g.checkpoints:
		var p: Vector2 = cp["pos"]
		var on: bool = str(g.save["cp"]) == str(cp["id"])
		draw_circle(p + Vector2(0, 14), 26.0, Color(0, 0, 0, 0.18))
		draw_rect(Rect2(p.x - 18.0, p.y + 2.0, 36.0, 16.0), Color("e9e2d0"))
		draw_rect(Rect2(p.x - 12.0, p.y - 6.0, 24.0, 10.0), Color("cfc6b0"))
		var bob: float = sin(t * 3.0) * 4.0
		var col: Color = Color("ffd84a") if on else Color("9fd8ff")
		var q: Vector2 = p + Vector2(0, -26.0 + bob)
		draw_colored_polygon(PackedVector2Array([q + Vector2(0, -14), q + Vector2(11, 0), q + Vector2(0, 14), q + Vector2(-11, 0)]), col)
		draw_colored_polygon(PackedVector2Array([q + Vector2(0, -8), q + Vector2(5, 0), q + Vector2(0, 4), q + Vector2(-5, 0)]), Color(1, 1, 1, 0.7))
		if on:
			draw_arc(p + Vector2(0, 10), 30.0 + sin(t * 2.0) * 3.0, 0.0, TAU, 28, Color(1.0, 0.85, 0.3, 0.5), 2.0)
	for f: Dictionary in g.open_finds:
		var fp: Vector2 = f["pos"]
		var fb: float = sin(t * 2.6 + fp.x) * 5.0
		var kind: String = str(f["kind"])
		draw_circle(fp + Vector2(0, 18), 14.0, Color(0, 0, 0, 0.18))
		var fq: Vector2 = fp + Vector2(0, fb - 4.0)
		draw_circle(fq, 22.0 + sin(t * 4.0) * 2.0, Color(1, 1, 0.7, 0.22))
		if kind == "heart":
			_heart(fq, 14.0, Color("ff5d7a"))
		elif kind == "ability":
			draw_circle(fq, 14.0, Color("38d6f0"))
			draw_circle(fq, 8.0, Color.WHITE)
			draw_arc(fq, 19.0, t * 3.0, t * 3.0 + 4.0, 16, Color("b8f4ff"), 3.0)
		else:
			_star(fq, 15.0, 7.0, t * 0.8, Color("ffe066"))
			_star(fq, 8.0, 4.0, t * 0.8, Color.WHITE)
	# walls on top of floor things
	for ty: int in range(y0, y1 + 1):
		for tx: int in range(x0, x1 + 1):
			if g.tiles[ty * g.mw + tx] == 1:
				_wall(tx, ty)
	# pickups
	for i: int in g.MAX_PICKS:
		var kk: int = g.k_kind[i]
		if kk == 0:
			continue
		var kp: Vector2 = g.k_pos[i]
		if kk == 1:
			draw_colored_polygon(PackedVector2Array([kp + Vector2(0, -8), kp + Vector2(6, 0), kp + Vector2(0, 8), kp + Vector2(-6, 0)]), Color("7df0c0"))
			draw_colored_polygon(PackedVector2Array([kp + Vector2(0, -4), kp + Vector2(3, 0), kp + Vector2(0, 2), kp + Vector2(-3, 0)]), Color.WHITE)
		else:
			_heart(kp, 9.0, Color("ff5d7a"))
	# enemies
	for e: Enemy in g.enemies:
		if e.alive:
			_enemy(e, t)
	# ship
	if g.phase != g.Phase.DEFEAT:
		_ship(t)
	# shots
	for i: int in g.MAX_BULLETS:
		var bk: int = g.b_kind[i]
		if bk == 0:
			continue
		var bp: Vector2 = g.b_pos[i]
		var br: float = g.b_r[i]
		if bk == 1:
			draw_circle(bp, br + 2.0, Color("3ad0e8"))
			draw_circle(bp, br - 1.0, Color("fffbe0"))
		else:
			draw_circle(bp, br + 2.5, Color("5a1040"))
			draw_circle(bp, br, Color("ff5fb0"))
			draw_circle(bp, br * 0.45, Color.WHITE)
	# sparks
	for i: int in g.MAX_PARTS:
		var life: float = g.p_life[i]
		if life > 0.0:
			var a: float = life / g.p_max[i]
			var pc: Color = g.p_col[i]
			pc.a *= a
			draw_circle(g.p_pos[i], g.p_size[i] * (0.4 + 0.6 * a), pc)

func _floor_bit(px: float, py: float, h: float) -> void:
	var o := Vector2(px + 12.0 + h * 240.0, py + 14.0 + fmod(h * 977.0, 1.0) * 36.0)
	if theme == "meadow":
		if h < 0.05:
			draw_circle(o, 5.0, Color("fff3a0"))
			draw_circle(o, 2.0, Color("f2913d"))
		else:
			draw_rect(Rect2(o.x, o.y, 3.0, 9.0), Color("5fae4a"))
			draw_rect(Rect2(o.x + 6.0, o.y + 2.0, 3.0, 7.0), Color("5fae4a"))
	elif theme == "cave":
		draw_circle(o, 4.0, Color("55527f"))
		if h < 0.04:
			draw_circle(o + Vector2(10, 4), 3.0, Color("8ee6ff", 0.6))
	else:
		draw_rect(Rect2(o.x, o.y, 14.0, 2.0), Color("a08a70"))

func _wall(tx: int, ty: int) -> void:
	var px: float = float(tx) * T
	var py: float = float(ty) * T
	var h: float = _hash(tx, ty)
	var below_open: bool = g.tile_at(tx, ty + 1) != 1
	if theme == "meadow":
		var c := Vector2(px + 32.0 + (h - 0.5) * 10.0, py + 30.0 + (fmod(h * 31.0, 1.0) - 0.5) * 10.0)
		draw_circle(c + Vector2(0, 8), 40.0, wall_a)
		draw_circle(c, 37.0, wall_b)
		draw_circle(c + Vector2(-9, -11), 21.0, wall_c)
		if h > 0.8:
			draw_circle(c + Vector2(12, 6), 5.0, Color("f06a6a"))
	elif theme == "cave":
		draw_rect(Rect2(px, py, T, T), wall_b)
		draw_rect(Rect2(px + 6.0, py + 5.0, T - 12.0, T - 16.0), wall_c)
		draw_rect(Rect2(px + 12.0 + h * 20.0, py + 12.0, 14.0, 5.0), wall_c.lightened(0.15))
		if below_open:
			draw_rect(Rect2(px, py + T - 12.0, T, 12.0), wall_a)
	else:
		draw_rect(Rect2(px, py, T, T), wall_b)
		draw_rect(Rect2(px + 2.0, py + 2.0, T - 4.0, 27.0), wall_c)
		var off: float = 0.0 if ty % 2 == 0 else 16.0
		draw_rect(Rect2(px + 2.0, py + 33.0, 28.0 + off, 27.0), wall_c)
		draw_rect(Rect2(px + 34.0 + off, py + 33.0, 28.0 - off, 27.0), wall_c)
		if below_open:
			draw_rect(Rect2(px, py + T - 10.0, T, 10.0), wall_a)

func _heart(p: Vector2, s: float, col: Color) -> void:
	draw_circle(p + Vector2(-s * 0.45, -s * 0.25), s * 0.55, col)
	draw_circle(p + Vector2(s * 0.45, -s * 0.25), s * 0.55, col)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-s * 0.95, 0), p + Vector2(s * 0.95, 0), p + Vector2(0, s)]), col)

func _star(p: Vector2, r1: float, r2: float, rot: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i: int in 10:
		var r: float = r1 if i % 2 == 0 else r2
		pts.append(p + Vector2.from_angle(rot + TAU * float(i) / 10.0 - PI / 2.0) * r)
	draw_colored_polygon(pts, col)

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

func _ship(t: float) -> void:
	var p: Vector2 = g.ppos
	var a: Vector2 = g.aim_dir
	var side: Vector2 = a.orthogonal()
	if g.invuln > 0.0 and g.dash_t <= 0.0 and int(t * 20.0) % 2 == 0:
		return
	draw_circle(p + Vector2(0, 14), 14.0, Color(0, 0, 0, 0.2))
	var mvn: Vector2 = g.pvel.normalized() if g.pvel.length_squared() > 100.0 else a
	var tail: float = 20.0 + minf(22.0, g.pvel.length() * 0.05) + sin(t * 22.0) * 3.0
	draw_colored_polygon(PackedVector2Array([p - mvn * tail - mvn * 8.0, p + mvn.orthogonal() * 12.0, p - mvn.orthogonal() * 12.0]), Color("ffb347"))
	draw_colored_polygon(PackedVector2Array([p - mvn * tail * 0.6 - mvn * 6.0, p + mvn.orthogonal() * 7.0, p - mvn.orthogonal() * 7.0]), Color("fff0a8"))
	draw_circle(p, 19.0, Color("1f3b63"))
	draw_circle(p, 16.0, Color("f7f3e6") if g.hurt_flash <= 0.0 else Color("ff8a8a"))
	draw_colored_polygon(PackedVector2Array([p + a * 27.0, p + a * 9.0 + side * 9.0, p + a * 9.0 - side * 9.0]), Color("1f3b63"))
	draw_colored_polygon(PackedVector2Array([p + a * 23.0, p + a * 10.0 + side * 6.0, p + a * 10.0 - side * 6.0]), Color("38c6e8"))
	draw_circle(p + a * 2.0, 7.0, Color("38c6e8"))
	draw_circle(p + a * 2.0 + Vector2(-2, -2), 2.5, Color.WHITE)
	if g.dash_t > 0.0:
		draw_arc(p, 25.0, 0.0, TAU, 20, Color(0.6, 0.95, 1.0, 0.8), 3.0)
