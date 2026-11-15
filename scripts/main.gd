extends Node2D
## Tiny Tailwind: game state and the rules of play.
## Movement, shots and hits are plain maths on a tile grid. No physics engine (E4.1 override).
## Everything that recurs in play (shots, sparks, pickups) lives in pools made once (E4.5).

const SaveStore := preload("res://addons/bc_common/save_store.gd")
const TestBridge := preload("res://addons/bc_common/test_bridge.gd")
const InputSetup := preload("res://addons/bc_common/input_setup.gd")
const Enemy := preload("res://scripts/enemy.gd")
const WorldView := preload("res://scripts/world_view.gd")
const Hud := preload("res://scripts/hud.gd")
const Bot := preload("res://scripts/bot.gd")

const VERSION := "0.2.1"
const T := 64.0
const PR := 17.0
const MAX_BULLETS := 700
const MAX_PARTS := 320
const MAX_PICKS := 160
const STAT_MAX := 5
const STATS: Array[String] = ["damage", "rate", "speed", "range"]
const STAT_NAMES: Dictionary = {"damage": "Power", "rate": "Fire rate", "speed": "Speed", "range": "Range"}
const DIFF_NAMES: Array[String] = ["Relaxed", "Normal", "Hard"]
const SPEEDS: Array[int] = [100, 85, 70, 50]
const AIM_NAMES: Array[String] = ["Off", "Light", "Strong", "Auto fire"]
const SHAKE_NAMES: Array[String] = ["Off", "Low", "Full"]
const SHAKE_K: Array[float] = [0.0, 0.4, 1.0]
const STICK_NAMES: Array[String] = ["Small", "Medium", "Large"]
const STICK_K: Array[float] = [0.8, 1.0, 1.3]
const TILE_FLOOR := 0
const TILE_WALL := 1
const TILE_WATER := 2
const TILE_RIFT := 3

enum Phase { TITLE, PLAY, DEFEAT, FADE_OUT, FADE_IN, END }

# ---- data ----
var world: Dictionary = {}
var enemy_defs: Dictionary = {}
var find_defs: Array[Dictionary] = []
var find_by_id: Dictionary = {}
var arena_ids: Array[String] = []
var cp_pos: Dictionary = {}          # checkpoint id -> [map id, Vector2]

# ---- save ----
var save: Dictionary = {
	"v": 1, "started": false, "cp": "m_glade", "xp": 0, "level": 1, "points": 0,
	"st_damage": 0, "st_rate": 0, "st_speed": 0, "st_range": 0,
	"finds": [], "flags": [], "seen": {},
	"defeats": 0, "kills": 0, "play_s": 0.0, "boss_s": 0.0,
	"difficulty": 1, "auto_aim": false, "speed_idx": 0, "invincible": false, "music": true, "sfx": true, "show_fps": false,
	"aim_assist": 1, "minimap": true, "shake": 2, "rumble": true, "stick_size": 1,
}
var store: SaveStore
var bridge: TestBridge

# ---- map ----
var map_id: String = ""
var map: Dictionary = {}
var mw: int = 0
var mh: int = 0
var tiles: PackedByteArray = PackedByteArray()
var gates: Dictionary = {}           # Vector2i -> arena id
var arenas: Array[Dictionary] = []
var active_arena: String = ""
var open_finds: Array[Dictionary] = []
var checkpoints: Array[Dictionary] = []
var doors: Array[Dictionary] = []
var enemies: Array[Enemy] = []
var boss: Enemy = null
var seen_now: Dictionary = {}        # chunk index -> true, for the current map

# ---- player ----
var phase: int = Phase.TITLE
var paused: bool = false
var ppos: Vector2 = Vector2.ZERO
var pvel: Vector2 = Vector2.ZERO
var aim_dir: Vector2 = Vector2.RIGHT
var hp: int = 6
var invuln: float = 0.0
var fire_cd: float = 0.0
var dash_t: float = 0.0
var dash_cd: float = 0.0
var dash_extra: float = 0.0
var dash_dir: Vector2 = Vector2.RIGHT
var dash_from: Vector2 = Vector2.ZERO
var dash_count: int = 0
var heal_cd: float = 0.0
var phase_t: float = 0.0
var pending_map: String = ""
var pending_pos: Vector2 = Vector2.ZERO
var boss_t: float = 0.0
var end_t: float = -1.0
var time: float = 0.0
var seen_t: float = 0.0
var shake: float = 0.0
var cam_look: Vector2 = Vector2.ZERO
var ship_ang: float = 0.0             # drawn heading, eased toward the aim so turns look smooth  # smoothed camera lead toward aim and travel
var proc_ms: float = 0.0
var hurt_flash: float = 0.0

# ---- input ----
var touch_move: Vector2 = Vector2.ZERO
var touch_aim: Vector2 = Vector2.ZERO
var touch_dash: bool = false
var touch_visible: bool = false
var mouse_active: bool = false
var mouse_down: bool = false
var using_pad: bool = false           # last input came from a controller
var pad_device: int = -1
var rumble_count: int = 0
var want_dash: bool = false
var audio_ok: bool = false
var firing: bool = false

# ---- pools ----
var b_pos: PackedVector2Array = PackedVector2Array()
var b_vel: PackedVector2Array = PackedVector2Array()
var b_life: PackedFloat32Array = PackedFloat32Array()
var b_kind: PackedByteArray = PackedByteArray()      # 0 free, 1 player shot, 2 enemy shot
var b_dmg: PackedFloat32Array = PackedFloat32Array()
var b_r: PackedFloat32Array = PackedFloat32Array()
var b_next: int = 0
var b_live: int = 0
var b_hi: int = 0                    # one past the highest shot slot in use, so loops stop early
var p_pos: PackedVector2Array = PackedVector2Array()
var p_vel: PackedVector2Array = PackedVector2Array()
var p_life: PackedFloat32Array = PackedFloat32Array()
var p_max: PackedFloat32Array = PackedFloat32Array()
var p_size: PackedFloat32Array = PackedFloat32Array()
var p_col: PackedColorArray = PackedColorArray()
var p_next: int = 0
var k_pos: PackedVector2Array = PackedVector2Array()
var k_vel: PackedVector2Array = PackedVector2Array()
var k_age: PackedFloat32Array = PackedFloat32Array()
var k_kind: PackedByteArray = PackedByteArray()      # 0 free, 1 crystal, 2 heart
var k_next: int = 0

# ---- nodes ----
var cam: Camera2D
var view: WorldView
var hud: Hud
var music: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_next: int = 0
var sounds: Dictionary = {}
var music_cache: Dictionary = {}
var music_now: String = ""
var shoot_alt: int = 0

# ---- test and bot ----
var bot: Bot = null
var bot_mode: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 20261115
	_load_data()
	_setup_input()
	InputSetup.add_controller_ui()      # G5.8: A chooses and B goes back in every menu
	_make_pools()
	store = SaveStore.new("user://tiny_tailwind.json")
	store.limits = {"xp": [0, 100000], "level": [1, 99], "points": [0, 99], "st_damage": [0, STAT_MAX], "st_rate": [0, STAT_MAX],
		"st_speed": [0, STAT_MAX], "st_range": [0, STAT_MAX], "defeats": [0, 1000000], "kills": [0, 10000000],
		"play_s": [0.0, 1.0e9], "boss_s": [0.0, 1.0e7], "difficulty": [0, 2], "speed_idx": [0, SPEEDS.size() - 1],
		"aim_assist": [0, 3], "shake": [0, 2], "stick_size": [0, 2]}
	var args: PackedStringArray = OS.get_cmdline_user_args()
	bot_mode = args.has("--bot") or args.has("--reach")
	if bot_mode:
		store.disabled = true
	store.load_into(save)
	_clean_save()
	bridge = TestBridge.new("tinytailwind")
	touch_visible = DisplayServer.is_touchscreen_available() and (OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"))

	cam = Camera2D.new()
	add_child(cam)
	cam.make_current()
	view = WorldView.new()
	view.g = self
	add_child(view)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.g = self
	layer.add_child(hud)
	_make_audio()
	if OS.has_feature("mobile"):
		Engine.max_fps = 60
	Input.joy_connection_changed.connect(_on_joy_changed)

	var cp: Array = cp_pos[str(save["cp"])]
	_load_map(str(cp[0]), cp[1])
	hp = max_hp()
	hud.show_title()
	if bot_mode:
		bot = Bot.new()
		bot.g = self
		if args.has("--reach"):
			var ok: bool = bot.reach_report()
			get_tree().quit(0 if ok else 1)
			return
		bot.begin()

func _load_data() -> void:
	world = _read_json("res://data/world.json")
	enemy_defs = _read_json("res://data/enemies.json")
	var fl: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/finds.json"))
	for f: Variant in (fl as Array):
		var fd: Dictionary = f
		find_defs.append(fd)
		find_by_id[str(fd["id"])] = fd
	var maps: Dictionary = world["maps"]
	for mid: Variant in maps.keys():
		var m: Dictionary = maps[mid]
		for c: Variant in (m["checkpoints"] as Array):
			var cd: Dictionary = c
			cp_pos[str(cd["id"])] = [str(mid), tile_center(int(cd["x"]), int(cd["y"]) + 1)]
		for a: Variant in (m["arenas"] as Array):
			var ad: Dictionary = a
			arena_ids.append(str(ad["id"]))

func _read_json(path: String) -> Dictionary:
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return v as Dictionary

## Saves are untrusted (E6.7). Drop ids and flags this build does not know.
func _clean_save() -> void:
	var finds: Array = []
	for f: Variant in (save["finds"] as Array):
		if f is String and find_by_id.has(f) and not finds.has(f):
			finds.append(f)
	save["finds"] = finds
	var flags: Array = []
	for f: Variant in (save["flags"] as Array):
		if f is String and arena_ids.has(f) and not flags.has(f):
			flags.append(f)
	save["flags"] = flags
	if not cp_pos.has(str(save["cp"])):
		save["cp"] = "m_glade"
	if bool(save["auto_aim"]):
		save["auto_aim"] = false          # v0.1 on/off auto aim becomes the Auto fire level. The old key stays (G5.6)
		save["aim_assist"] = 3
	var seen: Dictionary = {}
	var maps: Dictionary = world["maps"]
	for mid: Variant in (save["seen"] as Dictionary).keys():
		if not maps.has(mid):
			continue
		var out: Array = []
		var src: Variant = (save["seen"] as Dictionary)[mid]
		if src is Array:
			for c: Variant in (src as Array):
				if (c is int or c is float) and int(c) >= 0 and int(c) < 4096 and out.size() < 4096:
					out.append(int(c))
		seen[str(mid)] = out
	save["seen"] = seen

func _setup_input() -> void:
	_act("move_left", [KEY_A], JOY_AXIS_LEFT_X, -1.0)
	_act("move_right", [KEY_D], JOY_AXIS_LEFT_X, 1.0)
	_act("move_up", [KEY_W], JOY_AXIS_LEFT_Y, -1.0)
	_act("move_down", [KEY_S], JOY_AXIS_LEFT_Y, 1.0)
	_act("aim_left", [KEY_LEFT], JOY_AXIS_RIGHT_X, -1.0)
	_act("aim_right", [KEY_RIGHT], JOY_AXIS_RIGHT_X, 1.0)
	_act("aim_up", [KEY_UP], JOY_AXIS_RIGHT_Y, -1.0)
	_act("aim_down", [KEY_DOWN], JOY_AXIS_RIGHT_Y, 1.0)
	_joy_button("move_left", JOY_BUTTON_DPAD_LEFT)      # the D-pad flies the ship too
	_joy_button("move_right", JOY_BUTTON_DPAD_RIGHT)
	_joy_button("move_up", JOY_BUTTON_DPAD_UP)
	_joy_button("move_down", JOY_BUTTON_DPAD_DOWN)
	_act("dash", [KEY_SPACE, KEY_SHIFT], JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_joy_button("dash", JOY_BUTTON_A)
	_joy_button("dash", JOY_BUTTON_RIGHT_SHOULDER)
	_joy_button("dash", JOY_BUTTON_LEFT_SHOULDER)
	_act("menu", [KEY_ESCAPE], -1, 0.0)
	_joy_button("menu", JOY_BUTTON_BACK)
	_joy_button("menu", JOY_BUTTON_START)

func _act(action: String, keys: Array, axis: int, axis_value: float) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.3)
	for k: Variant in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = int(k) as Key
		InputMap.action_add_event(action, ev)
	if axis >= 0:
		var jm := InputEventJoypadMotion.new()
		jm.axis = axis as JoyAxis
		jm.axis_value = axis_value
		InputMap.action_add_event(action, jm)

func _joy_button(action: String, button: int) -> void:
	var jb := InputEventJoypadButton.new()
	jb.button_index = button as JoyButton
	InputMap.action_add_event(action, jb)

func _make_pools() -> void:
	b_pos.resize(MAX_BULLETS); b_vel.resize(MAX_BULLETS); b_life.resize(MAX_BULLETS)
	b_kind.resize(MAX_BULLETS); b_dmg.resize(MAX_BULLETS); b_r.resize(MAX_BULLETS)
	p_pos.resize(MAX_PARTS); p_vel.resize(MAX_PARTS); p_life.resize(MAX_PARTS)
	p_max.resize(MAX_PARTS); p_size.resize(MAX_PARTS); p_col.resize(MAX_PARTS)
	k_pos.resize(MAX_PICKS); k_vel.resize(MAX_PICKS); k_age.resize(MAX_PICKS); k_kind.resize(MAX_PICKS)

func _make_audio() -> void:
	music = AudioStreamPlayer.new()
	music.volume_db = -11.0
	add_child(music)
	for i: int in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	if bot_mode:
		return
	for n: String in ["shoot", "hit", "pop", "hurt", "crystal", "find", "dash", "checkpoint", "levelup", "gate", "boss", "click", "defeat"]:
		sounds[n] = load("res://audio/%s.wav" % n)

func sfx(n: String, vol_db: float = -6.0) -> void:
	if not audio_ok or not bool(save["sfx"]) or not sounds.has(n):
		return
	var p: AudioStreamPlayer = sfx_players[sfx_next]
	sfx_next = (sfx_next + 1) % sfx_players.size()
	p.stream = sounds[n]
	p.volume_db = vol_db
	p.play()

func play_music(n: String) -> void:
	music_now = n
	if not audio_ok or bot_mode:
		return
	if not bool(save["music"]):
		music.stop()
		return
	if not music_cache.has(n):
		var s: AudioStreamOggVorbis = load("res://audio/music_%s.ogg" % n)
		s.loop = true
		music_cache[n] = s
	if music.stream != music_cache[n] or not music.playing:
		music.stream = music_cache[n]
		music.play()

# ------------------------------------------------------------------ helpers

func tile_center(tx: int, ty: int) -> Vector2:
	return Vector2((float(tx) + 0.5) * T, (float(ty) + 0.5) * T)

func tile_at(tx: int, ty: int) -> int:
	if tx < 0 or ty < 0 or tx >= mw or ty >= mh:
		return TILE_WALL
	return tiles[ty * mw + tx]

func gate_closed(tx: int, ty: int) -> bool:
	if active_arena == "":
		return false
	var k := Vector2i(tx, ty)
	return gates.has(k) and str(gates[k]) == active_arena

func blocked(p: Vector2, r: float, water: bool, rift: bool) -> bool:
	var x0: int = int(floor((p.x - r) / T))
	var x1: int = int(floor((p.x + r) / T))
	var y0: int = int(floor((p.y - r) / T))
	var y1: int = int(floor((p.y + r) / T))
	for ty: int in range(y0, y1 + 1):
		for tx: int in range(x0, x1 + 1):
			var k: int = tile_at(tx, ty)
			var solid: bool = k == TILE_WALL or (water and k == TILE_WATER) or (rift and k == TILE_RIFT) or gate_closed(tx, ty)
			if not solid:
				continue
			var nx: float = clampf(p.x, float(tx) * T, float(tx + 1) * T)
			var ny: float = clampf(p.y, float(ty) * T, float(ty + 1) * T)
			var dx: float = p.x - nx
			var dy: float = p.y - ny
			if dx * dx + dy * dy < r * r:
				return true
	return false

func shot_blocked(p: Vector2) -> bool:
	var tx: int = int(floor(p.x / T))
	var ty: int = int(floor(p.y / T))
	return tile_at(tx, ty) == TILE_WALL or gate_closed(tx, ty)

func has_find(id: String) -> bool:
	return (save["finds"] as Array).has(id)

func has_dash() -> bool:
	return has_find("c_dash")

func has_flag(f: String) -> bool:
	return (save["flags"] as Array).has(f)

func max_hp() -> int:
	var hearts: int = 3
	for f: Variant in (save["finds"] as Array):
		var fd: Dictionary = find_by_id[str(f)]
		if str(fd["kind"]) == "heart":
			hearts += 1
	return hearts * 2

func stat(n: String) -> int:
	return int(save["st_" + n])

func xp_need() -> int:
	return 10 + int(save["level"]) * 6

func shot_damage() -> float:
	return 1.0 + 0.4 * float(stat("damage"))

func shot_interval() -> float:
	return 0.25 / (1.0 + 0.17 * float(stat("rate")))

func move_speed() -> float:
	return 300.0 + 20.0 * float(stat("speed"))

func shot_size() -> float:
	return 9.0 + float(stat("damage")) * 0.8

func shot_range() -> float:
	return 430.0 + 55.0 * float(stat("range"))

func difficulty() -> int:
	return int(save["difficulty"])

func say(text: String) -> void:
	if hud != null:
		hud.push_message(text)

func write_save() -> void:
	var seen: Dictionary = save["seen"]
	seen[map_id] = seen_now.keys()
	store.write(save)

# ------------------------------------------------------------------ map

func _load_map(id: String, spawn: Vector2) -> void:
	if map_id != "":
		var seen: Dictionary = save["seen"]
		seen[map_id] = seen_now.keys()
	map_id = id
	map = (world["maps"] as Dictionary)[id]
	mw = int(map["w"])
	mh = int(map["h"])
	tiles.resize(mw * mh)
	var rows: Array = map["rows"]
	for y: int in mh:
		var row: String = rows[y]
		for x: int in mw:
			var ch: String = row[x]
			var k: int = TILE_FLOOR
			if ch == "#":
				k = TILE_WALL
			elif ch == "~":
				k = TILE_WATER
			elif ch == "^":
				k = TILE_RIFT
			tiles[y * mw + x] = k
	gates.clear()
	arenas.clear()
	active_arena = ""
	for a: Variant in (map["arenas"] as Array):
		var ad: Dictionary = a
		arenas.append(ad)
		for gt: Variant in (ad["gates"] as Array):
			var ga: Array = gt
			gates[Vector2i(int(ga[0]), int(ga[1]))] = str(ad["id"])
	open_finds.clear()
	for f: Variant in (map["finds"] as Array):
		var fd: Dictionary = f
		if not has_find(str(fd["id"])):
			var def: Dictionary = find_by_id[str(fd["id"])]
			open_finds.append({"id": str(fd["id"]), "pos": tile_center(int(fd["x"]), int(fd["y"])), "kind": str(def["kind"])})
	checkpoints.clear()
	for c: Variant in (map["checkpoints"] as Array):
		var cd: Dictionary = c
		checkpoints.append({"id": str(cd["id"]), "pos": tile_center(int(cd["x"]), int(cd["y"]))})
	doors.clear()
	for d: Variant in (map["doors"] as Array):
		var dd: Dictionary = d
		doors.append({"tx": int(dd["x"]), "ty": int(dd["y"]), "pos": tile_center(int(dd["x"]), int(dd["y"])), "to": str(dd["to"]), "to_pos": tile_center(int(dd["tx"]), int(dd["ty"]))})
	enemies.clear()
	boss = null
	var i: int = 0
	for e: Variant in (map["enemies"] as Array):
		var ed: Dictionary = e
		i += 1
		var grp: String = str(ed["g"])
		if grp != "" and has_flag(grp):
			continue
		var en := Enemy.new()
		en.setup(str(ed["k"]), enemy_defs[str(ed["k"])], tile_center(int(ed["x"]), int(ed["y"])), grp, float(i) * 0.618)
		if en.move == "boss":
			en.dormant = true
			boss = en
		enemies.append(en)
	if boss != null:
		for j: int in 6:
			var add := Enemy.new()
			add.setup("mite", enemy_defs["mite"], boss.pos, "", float(j) * 1.37)
			add.alive = false
			add.is_add = true
			add.xp = 0
			enemies.append(add)
	for j: int in MAX_BULLETS:
		b_kind[j] = 0
	b_live = 0
	b_hi = 0
	for j: int in MAX_PICKS:
		k_kind[j] = 0
	for j: int in MAX_PARTS:
		p_life[j] = 0.0
	seen_now.clear()
	var sv: Dictionary = save["seen"]
	if sv.has(id):
		for c: Variant in (sv[id] as Array):
			seen_now[int(c)] = true
	ppos = spawn
	pvel = Vector2.ZERO
	cam_look = Vector2.ZERO
	dash_t = 0.0
	boss_t = 0.0
	_mark_seen()
	if cam != null:
		cam.position = _cam_target()
	play_music(str(map["music"]))
	if view != null:
		view.map_changed()

func go_map(id: String, spawn: Vector2) -> void:
	pending_map = id
	pending_pos = spawn
	phase = Phase.FADE_OUT
	phase_t = 0.0

func _mark_seen() -> void:
	var cx: int = int(ppos.x / (T * 4.0))
	var cy: int = int(ppos.y / (T * 4.0))
	var cw: int = int(ceil(float(mw) / 4.0))
	var ch: int = int(ceil(float(mh) / 4.0))
	for y: int in range(cy - 1, cy + 2):
		for x: int in range(cx - 2, cx + 3):
			if x >= 0 and y >= 0 and x < cw and y < ch:
				seen_now[y * cw + x] = true

func _cam_target() -> Vector2:
	var vs: Vector2 = get_viewport_rect().size
	var tgt: Vector2 = ppos + cam_look
	var half: Vector2 = vs * 0.5
	var wpx: float = float(mw) * T
	var hpx: float = float(mh) * T
	tgt.x = wpx * 0.5 if wpx <= vs.x else clampf(tgt.x, half.x, wpx - half.x)
	tgt.y = hpx * 0.5 if hpx <= vs.y else clampf(tgt.y, half.y, hpx - half.y)
	return tgt

# ------------------------------------------------------------------ flow

func start_game() -> void:
	save["started"] = true
	phase = Phase.PLAY
	paused = false
	hp = max_hp()
	play_music(music_now)
	if not bot_mode:
		write_save()

func to_title() -> void:
	write_save()
	phase = Phase.TITLE
	paused = false
	hud.show_title()

func erase_save() -> void:
	store.erase()
	get_tree().reload_current_scene()

func set_paused(p: bool) -> void:
	paused = p

func _notification(what: int) -> void:
	if SaveStore.is_save_moment(what) and store != null and map_id != "" and not bot_mode:
		write_save()
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and hud != null:
		hud.toggle_menu()
	# auto pause: leaving the game opens the Menu, so nothing happens while you are away
	if (what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED) and hud != null and phase == Phase.PLAY and not paused and not bot_mode:
		hud.toggle_menu()

func _on_joy_changed(device: int, connected: bool) -> void:
	# a controller that drops out mid-play opens the Menu
	if not connected and device == pad_device and phase == Phase.PLAY and not paused and hud != null and not bot_mode:
		hud.toggle_menu()

func rumble(weak: float, strong: float, secs: float) -> void:
	if bot_mode or not bool(save["rumble"]) or not using_pad or pad_device < 0:
		return
	rumble_count += 1
	Input.start_joy_vibration(pad_device, weak, strong, secs)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_first_input()
		using_pad = false
		touch_visible = true
		mouse_active = false
	elif event is InputEventKey or event is InputEventJoypadButton:
		_first_input()
		using_pad = event is InputEventJoypadButton
		if using_pad:
			pad_device = event.device
		touch_visible = false
		touch_move = Vector2.ZERO
		touch_aim = Vector2.ZERO
		if event is InputEventJoypadButton or (event is InputEventKey and (event as InputEventKey).physical_keycode in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]):
			mouse_active = false
	elif event is InputEventJoypadMotion:
		if absf((event as InputEventJoypadMotion).axis_value) > 0.5:
			using_pad = true
			pad_device = event.device
			touch_visible = false
			mouse_active = false
	elif event is InputEventMouse and event.device != InputEvent.DEVICE_ID_EMULATION:
		if event is InputEventMouseButton:
			_first_input()
			if not (event as InputEventMouseButton).pressed:
				mouse_down = false
		if event is InputEventMouseMotion and (event as InputEventMouseMotion).relative.length_squared() > 4.0:
			mouse_active = true
			touch_visible = false
	if event.is_action_pressed("menu") and hud != null:
		hud.toggle_menu()
	elif event is InputEventJoypadButton and event.is_action_pressed("ui_cancel") and hud != null and hud.menu_open:
		hud.toggle_menu()               # G5.8: B goes back
	if event.is_action_pressed("dash") and phase == Phase.PLAY and not paused:
		want_dash = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.device != InputEvent.DEVICE_ID_EMULATION:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT:
			mouse_down = mb.pressed
			mouse_active = true
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			want_dash = true

func _first_input() -> void:
	if audio_ok:
		return
	audio_ok = true
	play_music(music_now)

func _process(delta: float) -> void:
	if bot_mode:
		for i: int in 10:
			bot.think()
			_step(1.0 / 60.0)
			if bot.finished:
				get_tree().quit(0 if bot.ok else 1)
				return
		view.redraw()
		return
	var t_in: int = Time.get_ticks_usec()
	var cmd: String = bridge.tick(delta, _test_state)
	if cmd != "":
		_test_cmd(cmd)
	# E5.5: cap the frame step and take up to three smaller steps so a slow device stays in real time
	var dt: float = minf(delta, 0.1) * float(SPEEDS[int(save["speed_idx"])]) / 100.0
	var steps: int = clampi(int(ceil(dt / (1.0 / 30.0))), 1, 3)
	for i: int in steps:
		_step(dt / float(steps))
	# the camera leads a little toward where the ship aims and travels, eased so it never jumps
	var lead: Vector2 = (aim_dir * 48.0 if firing else Vector2.ZERO) + pvel * 0.1
	cam_look = cam_look.lerp(lead, 1.0 - exp(-delta * 3.0))
	ship_ang = lerp_angle(ship_ang, aim_dir.angle(), 1.0 - exp(-delta * 22.0))
	cam.position = cam.position.lerp(_cam_target(), 1.0 - exp(-delta * 10.0))
	shake = maxf(0.0, shake - delta * 30.0)
	var sk: float = shake * SHAKE_K[int(save["shake"])]
	cam.offset = Vector2(rng.randf_range(-sk, sk), rng.randf_range(-sk, sk)) if sk > 0.1 else Vector2.ZERO
	view.redraw()
	hud.queue_redraw()
	proc_ms = lerpf(proc_ms, float(Time.get_ticks_usec() - t_in) / 1000.0, 0.1)

func _step(dt: float) -> void:
	time += dt
	match phase:
		Phase.TITLE, Phase.END:
			_step_particles(dt)
			return
		Phase.FADE_OUT:
			phase_t += dt
			if phase_t >= 0.25:
				_load_map(pending_map, pending_pos)
				say(str(map["name"]))
				phase = Phase.FADE_IN
				phase_t = 0.0
			return
		Phase.FADE_IN:
			phase_t += dt
			if phase_t >= 0.25:
				phase = Phase.PLAY
			return
		Phase.DEFEAT:
			phase_t += dt
			_step_particles(dt)
			if phase_t >= 1.6:
				var cp: Array = cp_pos[str(save["cp"])]
				_load_map(str(cp[0]), cp[1])
				hp = max_hp()
				invuln = 1.5
				phase = Phase.PLAY
			return
	if paused:
		return
	save["play_s"] = float(save["play_s"]) + dt
	_step_player(dt)
	_step_enemies(dt)
	_step_bullets(dt)
	_step_pickups(dt)
	_step_particles(dt)
	_step_triggers(dt)
	if end_t >= 0.0:
		end_t -= dt
		if end_t < 0.0:
			phase = Phase.END
			write_save()
			hud.show_end()

# ------------------------------------------------------------------ player

func _step_player(dt: float) -> void:
	var mv: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if touch_move.length_squared() > 0.01:
		mv = touch_move
	var aim: Vector2 = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	firing = false
	var stick_aim: bool = false
	if bot_mode:
		mv = bot.move
		if bot.fire:
			aim_dir = bot.aim
			firing = true
		if bot.dash:
			want_dash = true
	elif aim.length_squared() > 0.06:
		aim_dir = aim.normalized()
		firing = true
		stick_aim = true
	elif touch_aim.length_squared() > 0.04:
		aim_dir = touch_aim.normalized()
		firing = true
		stick_aim = true
	elif mouse_active:
		var to_mouse: Vector2 = get_global_mouse_position() - ppos
		if to_mouse.length_squared() > 36.0:
			aim_dir = to_mouse.normalized()
		firing = mouse_down
	var assist: int = int(save["aim_assist"])
	if assist > 0 and assist < 3 and stick_aim and not bot_mode:
		aim_dir = _assist_aim(aim_dir, assist)
	if assist == 3 and not bot_mode:
		var tgt: Enemy = nearest_enemy(shot_range() * 1.05)
		if tgt != null:
			aim_dir = (tgt.pos - ppos).normalized()
			firing = true
		elif not firing and mv.length_squared() > 0.04:
			aim_dir = mv.normalized()
	if mv.length_squared() > 1.0:
		mv = mv.normalized()

	invuln = maxf(0.0, invuln - dt)
	hurt_flash = maxf(0.0, hurt_flash - dt)
	dash_cd = maxf(0.0, dash_cd - dt)
	heal_cd = maxf(0.0, heal_cd - dt)
	if (want_dash or touch_dash) and has_dash() and dash_cd <= 0.0 and dash_t <= 0.0:
		dash_dir = mv.normalized() if mv.length_squared() > 0.04 else aim_dir
		dash_t = 0.2
		dash_count += 1
		dash_extra = 0.0
		dash_cd = 0.9
		dash_from = ppos
		sfx("dash", -8.0)
		rumble(0.25, 0.0, 0.08)
		for i: int in 8:
			spark(ppos, -dash_dir * rng.randf_range(40.0, 160.0) + Vector2(rng.randf_range(-60, 60), rng.randf_range(-60, 60)), 0.35, 5.0, Color(0.55, 0.95, 1.0))
	want_dash = false
	touch_dash = false

	var dashing: bool = dash_t > 0.0
	if dashing:
		pvel = dash_dir * move_speed() * 3.7
		dash_t -= dt
		if rng.randf() < 0.7:
			spark(ppos, Vector2.ZERO, 0.25, 9.0, Color(0.6, 0.95, 1.0, 0.7))
	else:
		# ease toward the stick: 63% of the way in 40 ms, 95% in 120 ms. Quick, with no jolt on start or stop.
		pvel = pvel.lerp(mv * move_speed(), 1.0 - exp(-dt * 25.0))
		if mv == Vector2.ZERO and pvel.length_squared() < 9.0:
			pvel = Vector2.ZERO
	var v: Vector2 = pvel
	var np: Vector2 = ppos + Vector2(v.x * dt, 0.0)
	if not blocked(np, PR, true, not dashing):
		ppos = np
	elif absf(v.x) > 40.0 and absf(v.y) < absf(v.x) * 0.35:
		ppos.y += _corner_nudge(np, Vector2(0.0, 1.0), absf(v.x) * dt, dashing)
	np = ppos + Vector2(0.0, v.y * dt)
	if not blocked(np, PR, true, not dashing):
		ppos = np
	elif absf(v.y) > 40.0 and absf(v.x) < absf(v.y) * 0.35:
		ppos.x += _corner_nudge(np, Vector2(1.0, 0.0), absf(v.y) * dt, dashing)
	if dashing and dash_t <= 0.0:
		# a dash that ends over a rift carries a little further. If it still ends over the rift, go back. Nothing is lost.
		if _over_rift(ppos):
			if dash_extra < 0.16:
				dash_extra += dt
				dash_t = 0.0001
			else:
				ppos = dash_from
				for i: int in 10:
					spark(ppos, Vector2.from_angle(rng.randf() * TAU) * 90.0, 0.4, 5.0, Color(0.8, 0.9, 1.0))
	elif not dashing and _over_rift(ppos):
		ppos = dash_from

	fire_cd -= dt
	if firing and fire_cd <= 0.0:
		fire_cd = shot_interval()
		var life: float = shot_range() / 780.0
		shoot(1, ppos + aim_dir * 20.0, aim_dir * 780.0 + pvel * 0.15, life, shot_damage(), shot_size())
		shoot_alt += 1
		if shoot_alt % 2 == 0:
			sfx("shoot", -17.0)
	if mv.length_squared() > 0.05 and rng.randf() < 0.5:
		spark(ppos - mv.normalized() * 14.0, -mv * 60.0 + Vector2(rng.randf_range(-20, 20), rng.randf_range(-20, 20)), 0.3, 4.0, Color(1.0, 0.85, 0.45, 0.8))

## When the ship flies straight into the edge of a wall, slide it sideways around the corner instead of stopping dead.
func _corner_nudge(np: Vector2, side: Vector2, step: float, dashing: bool) -> float:
	for n: float in [5.0, 10.0, 16.0]:
		for s: float in [-1.0, 1.0]:
			var off: Vector2 = side * minf(n, step) * s
			if not blocked(np + side * n * s, PR, true, not dashing) and not blocked(ppos + off, PR, true, not dashing):
				return minf(n, step) * s
	return 0.0

## Aim assist for sticks and touch: bends the aim toward the enemy closest to where you point.
## Light pulls 60% of the way within about 12 degrees. Strong pulls all the way within about 24 degrees.
func _assist_aim(dir: Vector2, level: int) -> Vector2:
	var cone: float = 0.21 if level == 1 else 0.42
	var pull: float = 0.6 if level == 1 else 1.0
	var best: Enemy = null
	var best_a: float = cone
	var r2: float = shot_range() * shot_range()
	for e: Enemy in enemies:
		if not e.alive or not e.awake or e.dormant:
			continue
		var to: Vector2 = e.pos - ppos
		if to.length_squared() > r2:
			continue
		var a: float = absf(dir.angle_to(to))
		if a < best_a:
			best_a = a
			best = e
	if best == null:
		return dir
	return dir.slerp((best.pos - ppos).normalized(), pull)

func _over_rift(p: Vector2) -> bool:
	return tile_at(int(floor(p.x / T)), int(floor(p.y / T))) == TILE_RIFT

func nearest_enemy(max_d: float) -> Enemy:
	var best: Enemy = null
	var bd: float = max_d * max_d
	for e: Enemy in enemies:
		if not e.alive or not e.awake or e.dormant:
			continue
		var d: float = e.pos.distance_squared_to(ppos)
		if d < bd:
			bd = d
			best = e
	return best

func hurt_player(dmg: int) -> void:
	if invuln > 0.0 or dash_t > 0.0 or phase != Phase.PLAY:
		return
	invuln = [1.5, 1.0, 0.8][difficulty()]
	hurt_flash = 0.25
	shake = 9.0
	sfx("hurt")
	rumble(0.4, 0.7, 0.2)
	if bool(save["invincible"]):
		return
	hp -= dmg * (2 if difficulty() == 2 else 1)
	for i: int in 10:
		spark(ppos, Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(80.0, 220.0), 0.45, 5.0, Color(1.0, 0.5, 0.5))
	if hp <= 0:
		hp = 0
		phase = Phase.DEFEAT
		phase_t = 0.0
		active_arena = ""
		save["defeats"] = int(save["defeats"]) + 1
		sfx("defeat")
		for i: int in 26:
			spark(ppos, Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 320.0), 0.9, 7.0, Color(1.0, 0.9, 0.6))

# ------------------------------------------------------------------ shots, sparks, pickups

func shoot(kind: int, pos: Vector2, vel: Vector2, life: float, dmg: float, r: float) -> void:
	for n: int in MAX_BULLETS:
		var i: int = (b_next + n) % MAX_BULLETS
		if b_kind[i] == 0:
			b_kind[i] = kind
			b_pos[i] = pos
			b_vel[i] = vel
			b_life[i] = life
			b_dmg[i] = dmg
			b_r[i] = r
			b_next = (i + 1) % MAX_BULLETS
			b_hi = maxi(b_hi, i + 1)
			return

func spark(pos: Vector2, vel: Vector2, life: float, size: float, col: Color) -> void:
	if bot_mode:
		return
	var i: int = p_next
	p_next = (p_next + 1) % MAX_PARTS
	p_pos[i] = pos
	p_vel[i] = vel
	p_life[i] = life
	p_max[i] = life
	p_size[i] = size
	p_col[i] = col

func drop(kind: int, pos: Vector2) -> void:
	for n: int in MAX_PICKS:
		var i: int = (k_next + n) % MAX_PICKS
		if k_kind[i] == 0:
			k_kind[i] = kind
			k_pos[i] = pos
			k_vel[i] = Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 200.0)
			k_age[i] = 0.0
			k_next = (i + 1) % MAX_PICKS
			return

func _step_bullets(dt: float) -> void:
	var live: int = 0
	var top: int = 0
	var hit_r: float = PR * 0.5
	for i: int in b_hi:
		var kind: int = b_kind[i]
		if kind == 0:
			continue
		var life: float = b_life[i] - dt
		var pos: Vector2 = b_pos[i] + b_vel[i] * dt
		if life <= 0.0 or shot_blocked(pos):
			b_kind[i] = 0
			if life > 0.0:
				spark(pos, -b_vel[i] * 0.1, 0.18, 4.0, Color(1, 1, 0.8) if kind == 1 else Color(1.0, 0.5, 0.8))
			continue
		b_life[i] = life
		b_pos[i] = pos
		live += 1
		top = i + 1
		if kind == 1:
			var br: float = b_r[i]
			for e: Enemy in enemies:
				if not e.alive or e.dormant:
					continue
				var rr: float = e.r + br
				if e.pos.distance_squared_to(pos) < rr * rr:
					b_kind[i] = 0
					damage_enemy(e, b_dmg[i], pos)
					break
		else:
			var rr2: float = hit_r + b_r[i]
			if pos.distance_squared_to(ppos) < rr2 * rr2:
				b_kind[i] = 0
				hurt_player(1)
	b_live = live
	b_hi = top

func _step_particles(dt: float) -> void:
	for i: int in MAX_PARTS:
		if p_life[i] > 0.0:
			p_life[i] -= dt
			p_pos[i] += p_vel[i] * dt
			p_vel[i] *= 1.0 - minf(1.0, dt * 3.0)

func _step_pickups(dt: float) -> void:
	for i: int in MAX_PICKS:
		var kind: int = k_kind[i]
		if kind == 0:
			continue
		k_age[i] += dt
		var pos: Vector2 = k_pos[i]
		var d2: float = pos.distance_squared_to(ppos)
		if k_age[i] > 0.3 and d2 < 190.0 * 190.0:
			k_vel[i] = (ppos - pos).normalized() * 520.0
		else:
			k_vel[i] *= 1.0 - minf(1.0, dt * 4.0)
		var np: Vector2 = pos + k_vel[i] * dt
		if not shot_blocked(np):
			k_pos[i] = np
		if d2 < 26.0 * 26.0 and k_age[i] > 0.15:
			k_kind[i] = 0
			if kind == 1:
				gain_xp(1)
			else:
				hp = mini(max_hp(), hp + 2)
				sfx("checkpoint", -12.0)
		elif k_age[i] > 40.0:
			k_kind[i] = 0

func gain_xp(n: int) -> void:
	save["xp"] = int(save["xp"]) + n
	sfx("crystal", -14.0)
	while int(save["xp"]) >= xp_need():
		save["xp"] = int(save["xp"]) - xp_need()
		save["level"] = int(save["level"]) + 1
		save["points"] = int(save["points"]) + 1
		say("Level %d. Spend a point: Menu, then Ship." % int(save["level"]))
		sfx("levelup")
		if bot_mode:
			bot.spend_points()

func spend_point(st: String) -> bool:
	if int(save["points"]) <= 0 or stat(st) >= STAT_MAX:
		return false
	save["points"] = int(save["points"]) - 1
	save["st_" + st] = stat(st) + 1
	if not bot_mode:
		write_save()
	return true

# ------------------------------------------------------------------ enemies

func damage_enemy(e: Enemy, dmg: float, at: Vector2) -> void:
	e.hp -= dmg
	e.flash = 0.1
	e.bar_t = 2.5
	e.awake = true
	spark(at, Vector2.from_angle(rng.randf() * TAU) * 120.0, 0.2, 4.0, Color(1, 1, 0.85))
	if e.hp > 0.0:
		sfx("hit", -15.0)
		return
	e.alive = false
	save["kills"] = int(save["kills"]) + 1
	sfx("pop", -8.0)
	shake = maxf(shake, 3.0)
	for i: int in int(10.0 + e.r * 0.4):
		spark(e.pos, Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 260.0), 0.5, 6.0, e.color.lightened(rng.randf() * 0.4))
	for i: int in e.xp:
		drop(1, e.pos)
	if rng.randf() < 0.09 and hp < max_hp():
		drop(2, e.pos)
	if e == boss:
		_boss_down()
	elif e.group != "":
		_check_arena(e.group)

func _check_arena(grp: String) -> void:
	for e: Enemy in enemies:
		if e.alive and e.group == grp:
			return
	if not has_flag(grp):
		(save["flags"] as Array).append(grp)
	if active_arena == grp:
		active_arena = ""
		sfx("gate")
		say("The way opens.")
	if not bot_mode:
		write_save()

func _boss_down() -> void:
	for e: Enemy in enemies:
		if e.is_add and e.alive:
			e.alive = false
	for i: int in MAX_BULLETS:
		if b_kind[i] == 2:
			b_kind[i] = 0
	shake = 16.0
	sfx("boss")
	rumble(0.6, 1.0, 0.5)
	if float(save["boss_s"]) <= 0.0 or boss_t < float(save["boss_s"]):
		save["boss_s"] = boss_t
	_check_arena("d_boss")
	say("Thornhull is calm. The keep is quiet.")
	play_music(str(map["music"]))
	end_t = 4.0

func _step_enemies(dt: float) -> void:
	var diff: int = difficulty()
	var rate_k: float = [1.3, 1.0, 0.8][diff]
	var bs_k: float = [0.8, 1.0, 1.18][diff]
	for e: Enemy in enemies:
		if not e.alive:
			continue
		var to: Vector2 = ppos - e.pos
		var d2: float = to.length_squared()
		if e.dormant:
			continue
		if not e.awake:
			if d2 < 620.0 * 620.0:
				e.awake = true
			else:
				continue
		elif d2 > 1100.0 * 1100.0 and e != boss:
			e.awake = false
			continue
		e.flash = maxf(0.0, e.flash - dt)
		e.bar_t = maxf(0.0, e.bar_t - dt)
		e.ang += dt
		var dn: Vector2 = to / maxf(1.0, sqrt(d2))
		var v: Vector2 = Vector2.ZERO
		match e.move:
			"chase":
				v = dn * e.speed
			"swarm":
				v = (dn + dn.orthogonal() * sin(e.ang * 5.0 + e.seed * 9.0) * 0.8).normalized() * e.speed
			"wander":
				v = Vector2(cos(e.ang * 0.7 + e.seed), sin(e.ang * 0.9 + e.seed * 2.0)) * e.speed
				if e.pos.distance_squared_to(e.home) > 150.0 * 150.0:
					v = (e.home - e.pos).normalized() * e.speed
			"keep_away":
				if d2 < 230.0 * 230.0:
					v = -dn * e.speed
				elif d2 > 380.0 * 380.0:
					v = dn * e.speed
				else:
					v = dn.orthogonal() * e.speed * (1.0 if fmod(e.seed, 2.0) < 1.0 else -1.0)
			"charge":
				e.st_t -= dt
				if e.state == 0:
					v = dn * e.speed
					if d2 < 360.0 * 360.0 and e.st_t <= 0.0:
						e.state = 1
						e.st_t = 0.55
				elif e.state == 1:
					e.dir = dn
					e.flash = 0.05
					if e.st_t <= 0.0:
						e.state = 2
						e.st_t = 0.5
				else:
					v = e.dir * 540.0
					if e.st_t <= 0.0:
						e.state = 0
						e.st_t = 1.3
			"boss":
				_boss_step(e, dt, dn, bs_k, rate_k)
				var c: Vector2 = e.home + Vector2(cos(e.ang * 0.5) * 220.0, sin(e.ang * 0.8) * 250.0)
				v = (c - e.pos).limit_length(1.0) * e.speed * (1.5 if e.phase2 else 1.0)
		if v != Vector2.ZERO:
			var np: Vector2 = e.pos + Vector2(v.x * dt, 0.0)
			if not blocked(np, e.r * 0.8, true, true):
				e.pos = np
			elif e.state == 2:
				e.st_t = 0.0
			np = e.pos + Vector2(0.0, v.y * dt)
			if not blocked(np, e.r * 0.8, true, true):
				e.pos = np
			elif e.state == 2:
				e.st_t = 0.0
		if e.fire != "none" and e.fire != "boss":
			e.fire_t -= dt
			if e.fire_t <= 0.0 and d2 < 600.0 * 600.0:
				e.fire_t = e.rate * rate_k
				if _clear_line(e.pos, ppos):
					_enemy_fire(e, dn, bs_k)
		var tr: float = e.r * 0.8 + PR * 0.6
		if d2 < tr * tr:
			hurt_player(e.touch)

func _clear_line(a: Vector2, b: Vector2) -> bool:
	var n: int = int(a.distance_to(b) / 40.0)
	for i: int in range(1, n):
		if shot_blocked(a.lerp(b, float(i) / float(n))):
			return false
	return true

func _enemy_fire(e: Enemy, dn: Vector2, bs_k: float) -> void:
	var sp: float = e.bspeed * bs_k
	match e.fire:
		"aimed":
			shoot(2, e.pos + dn * e.r, dn * sp, 3.2, 1.0, 8.0)
		"ring":
			var off: float = e.ang * 0.6
			for i: int in e.count:
				var d: Vector2 = Vector2.from_angle(off + TAU * float(i) / float(e.count))
				shoot(2, e.pos + d * e.r, d * sp, 3.4, 1.0, 8.0)
		"fan":
			for i: int in e.count:
				var d2: Vector2 = dn.rotated((float(i) - float(e.count - 1) * 0.5) * e.spread)
				shoot(2, e.pos + d2 * e.r, d2 * sp, 3.0, 1.0, 8.0)

func _boss_step(e: Enemy, dt: float, dn: Vector2, bs_k: float, rate_k: float) -> void:
	boss_t += dt
	if not e.phase2 and e.hp < e.max_hp * 0.5:
		e.phase2 = true
		sfx("boss")
		shake = 10.0
		say("Thornhull bristles.")
		var n: int = 0
		for a: Enemy in enemies:
			if a.is_add and not a.alive and n < 4:
				a.alive = true
				a.awake = true
				a.hp = a.max_hp
				a.pos = e.pos + Vector2.from_angle(TAU * float(n) / 4.0) * 90.0
				n += 1
	var sp: float = e.bspeed * bs_k
	e.st_t -= dt
	e.fire_t -= dt
	if e.st_t <= 0.0:
		e.state = (e.state + 1) % 4       # 0 rest, 1 rings, 2 fans, 3 spiral
		e.st_t = [1.4, 4.0, 3.4, 3.6][e.state] * (0.7 if e.state == 0 and e.phase2 else 1.0)
		e.fire_t = 0.3
	if e.fire_t > 0.0:
		return
	match e.state:
		1:
			e.fire_t = 0.95 * rate_k
			var cnt: int = e.count + (4 if e.phase2 else 0)
			var off: float = e.ang * 0.9
			for i: int in cnt:
				var d: Vector2 = Vector2.from_angle(off + TAU * float(i) / float(cnt))
				shoot(2, e.pos + d * e.r, d * sp, 4.5, 1.0, 9.0)
		2:
			e.fire_t = 0.62 * rate_k
			var m: int = 7 if e.phase2 else 5
			for i: int in m:
				var d2: Vector2 = dn.rotated((float(i) - float(m - 1) * 0.5) * 0.2)
				shoot(2, e.pos + d2 * e.r, d2 * sp * 1.25, 4.0, 1.0, 9.0)
		3:
			e.fire_t = 0.085 * rate_k
			var arms: int = 3 if e.phase2 else 2
			for i: int in arms:
				var d3: Vector2 = Vector2.from_angle(e.ang * 2.6 + TAU * float(i) / float(arms))
				shoot(2, e.pos + d3 * e.r, d3 * sp * 0.95, 4.5, 1.0, 8.0)

# ------------------------------------------------------------------ finds, checkpoints, doors, arenas

func _step_triggers(dt: float) -> void:
	seen_t -= dt
	if seen_t <= 0.0:
		seen_t = 0.3
		_mark_seen()
	for i: int in range(open_finds.size() - 1, -1, -1):
		var f: Dictionary = open_finds[i]
		var fp: Vector2 = f["pos"]
		if fp.distance_squared_to(ppos) < 40.0 * 40.0:
			open_finds.remove_at(i)
			_collect(str(f["id"]), fp)
	for c: Dictionary in checkpoints:
		var cp: Vector2 = c["pos"]
		if cp.distance_squared_to(ppos) < 60.0 * 60.0:
			if str(save["cp"]) != str(c["id"]):
				save["cp"] = str(c["id"])
				say("Checkpoint. Progress saved.")
				sfx("checkpoint")
				hp = max_hp()
				heal_cd = 3.0
				if not bot_mode:
					write_save()
			elif heal_cd <= 0.0 and hp < max_hp():
				hp = max_hp()
				heal_cd = 3.0
				sfx("checkpoint", -10.0)
	var tx: int = int(floor(ppos.x / T))
	var ty: int = int(floor(ppos.y / T))
	for d: Dictionary in doors:
		if int(d["tx"]) == tx and int(d["ty"]) == ty:
			go_map(str(d["to"]), d["to_pos"])
			return
	if active_arena == "":
		for a: Dictionary in arenas:
			var id: String = str(a["id"])
			if has_flag(id):
				continue
			var r: Array = a["rect"]
			if tx >= int(r[0]) and tx <= int(r[2]) and ty >= int(r[1]) and ty <= int(r[3]):
				active_arena = id
				sfx("gate")
				for e: Enemy in enemies:
					if e.alive and e.group == id:
						e.awake = true
				if boss != null and boss.group == id:
					boss.dormant = false
					boss.state = 0
					boss.st_t = 1.6
					boss_t = 0.0
					sfx("boss")
					play_music("boss")
					say("Thornhull, warden of the keep.")
				else:
					say("The gates close. Clear the room.")

func _collect(id: String, at: Vector2) -> void:
	var def: Dictionary = find_by_id[id]
	(save["finds"] as Array).append(id)
	var n: int = (save["finds"] as Array).size()
	sfx("find")
	for i: int in 18:
		spark(at, Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 220.0), 0.7, 6.0, Color(1.0, 0.95, 0.6))
	var kind: String = str(def["kind"])
	if kind == "heart":
		hp = max_hp()
		say("Found %s. One more heart. (%d of %d)" % [str(def["name"]), n, find_defs.size()])
	elif kind == "ability":
		say("Found the Dash Core. Dash crosses rifts. (%d of %d)" % [n, find_defs.size()])
		hud.push_message(hud.dash_hint())
	else:
		say("Found %s. (%d of %d)" % [str(def["name"]), n, find_defs.size()])
	if not bot_mode:
		write_save()

# ------------------------------------------------------------------ test hooks (G7.8: only with ?test, never in the APK)

func _test_state() -> Dictionary:
	var awake: int = 0
	var alive: int = 0
	for e: Enemy in enemies:
		if e.alive:
			alive += 1
			if e.awake:
				awake += 1
	return {"phase": phase, "paused": paused, "map": map_id, "x": snappedf(ppos.x, 0.1), "y": snappedf(ppos.y, 0.1), "hp": hp, "max_hp": max_hp(),
		"finds": (save["finds"] as Array).size(), "level": int(save["level"]), "xp": int(save["xp"]), "points": int(save["points"]),
		"alive": alive, "awake": awake, "shots": b_live, "menu": hud.menu_open, "tab": hud.tab, "touch": touch_visible,
		"dash": has_dash(), "flags": save["flags"], "cp": str(save["cp"]), "arena": active_arena, "kills": int(save["kills"]),
		"defeats": int(save["defeats"]), "difficulty": int(save["difficulty"]), "focus": hud.focus_text(), "dash_cd": dash_cd, "dashes": dash_count, "aim_assist": int(save["aim_assist"]), "mini": hud.mini_shown(), "rumbles": rumble_count, "shot_r": shot_size(), "minimap": bool(save["minimap"]), "fps": Engine.get_frames_per_second(), "proc_ms": snappedf(proc_ms, 0.01), "draw_ms": snappedf(view.draw_ms, 0.01), "speed": snappedf(pvel.length(), 0.1), "pads": Input.get_connected_joypads().size(), "pad_line": hud.pad_text(), "boss_hp": boss.hp if boss != null else -1.0, "version": VERSION}

func _test_cmd(cmd: String) -> void:
	var maps: Dictionary = world["maps"]
	match cmd:
		"start":
			hud.hide_title()
			start_game()
		"menu":
			hud.toggle_menu()
		"tab_ship", "tab_journal", "tab_map", "tab_settings":
			hud.open_tab(cmd.substr(4))
		"give_dash":
			if not has_dash():
				_collect("c_dash", ppos)
		"warp_cave":
			go_map("cave", tile_center(3, 12))
		"warp_dungeon":
			go_map("dungeon", tile_center(3, 17))
		"warp_core":
			go_map("cave", tile_center(21, 12))
		"heal":
			hp = max_hp()
		"warp_boss":
			go_map("dungeon", tile_center(36, 17))
		"warp_cross":
			go_map("meadow", tile_center(24, 17))
		"hurt":
			invuln = 0.0
			hurt_player(1)
		"defeat":
			invuln = 0.0
			hp = 1
			hurt_player(1)
		"boss_low":
			if boss != null:
				boss.hp = 3.0
		"xp":
			gain_xp(xp_need())
		"win":
			if boss != null and boss.alive:
				damage_enemy(boss, 100000.0, boss.pos)
		"end":
			hud.close_end()
		"low":
			hp = 1
		"focus_out":
			_notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		_:
			if cmd.begins_with("set_"):
				hud._on_setting(cmd.substr(4))
