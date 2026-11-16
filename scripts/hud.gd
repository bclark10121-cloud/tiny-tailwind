extends Control
## HUD, touch controls, the Menu row (G5.1), title card (G5.5) and end card. Built once in code.
## While playing the screen shows hearts, the dash bar, level, the find counter and touch controls (G5.2 with override 3).

const TABS: Array[String] = ["ship", "journal", "map", "settings"]
const TAB_NAMES: Dictionary = {"ship": "Ship", "journal": "Journal", "map": "Map", "settings": "Settings"}

## The corner mini map: the tiles are drawn only when the map or the explored area changes. The dots redraw every frame.
class MiniBase extends Control:
	var h: Control
	func _draw() -> void:
		h.draw_mini_base(self)

class MiniDots extends Control:
	var h: Control
	func _draw() -> void:
		h.draw_mini_dots(self)

var g: Node2D
var font: Font
var menu_open: bool = false
var tab: String = "ship"
var menu_btn: Button
var row: HBoxContainer
var row_btns: Dictionary = {}
var panel: PanelContainer
var pages: Dictionary = {}
var title: Control
var start_btn: Button
var end_card: Control
var end_label: Label
var ship_points: Label
var ship_rows: Dictionary = {}
var journal_grid: GridContainer
var journal_head: Label
var map_ctl: Control
var set_btns: Dictionary = {}
var erase_armed: bool = false
var pad_title: Label
var mini_base: MiniBase
var mini_dots: MiniDots
var mini_s: float = 3.0
var mini_map_id: String = ""
var mini_seen: int = -1
var shop_open: bool = false
var shop_panel: PanelContainer
var shop_coins: Label
var shop_info: Label
var shop_close: Button
var shop_rows: Dictionary = {}
var pad_settings: Label
var messages: Array[String] = []
var msg_t: float = 0.0
var sm: Rect2 = Rect2()          # safe area in HUD units (E5.3)
# touch sticks
var move_id: int = -1
var aim_id: int = -1
var move_o: Vector2 = Vector2.ZERO
var aim_o: Vector2 = Vector2.ZERO
var move_p: Vector2 = Vector2.ZERO
var aim_p: Vector2 = Vector2.ZERO
var dash_c: Vector2 = Vector2.ZERO

func _ready() -> void:
	font = ThemeDB.fallback_font
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = _make_theme()
	menu_btn = _button("Menu", toggle_menu)
	menu_btn.custom_minimum_size = Vector2(124, 56)
	add_child(menu_btn)
	mini_base = MiniBase.new()
	mini_base.h = self
	mini_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(mini_base)
	mini_dots = MiniDots.new()
	mini_dots.h = self
	mini_dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mini_base.add_child(mini_dots)
	row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.visible = false
	add_child(row)
	for t: String in TABS:
		var b: Button = _button(str(TAB_NAMES[t]), open_tab.bind(t))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
		row_btns[t] = b
	var tb: Button = _button("Title", _on_title)
	tb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(tb)
	panel = PanelContainer.new()
	panel.visible = false
	add_child(panel)
	var holder := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		holder.add_theme_constant_override("margin_" + side, 18)
	panel.add_child(holder)
	_build_ship(holder)
	_build_journal(holder)
	_build_map(holder)
	_build_settings(holder)
	_build_title()
	_build_end()
	_build_shop()
	get_viewport().size_changed.connect(_layout)
	Input.joy_connection_changed.connect(_on_pad_changed)
	_on_pad_changed(0, false)
	_layout()

func _make_theme() -> Theme:
	var th := Theme.new()
	th.default_font_size = 22
	var cols: Dictionary = {"normal": Color("24365c"), "hover": Color("2f4878"), "pressed": Color("1a2947"), "focus": Color("2f4878"), "disabled": Color("3a4050")}
	for k: Variant in cols.keys():
		var sb := StyleBoxFlat.new()
		sb.bg_color = cols[k]
		sb.set_corner_radius_all(12)
		sb.set_content_margin_all(10)
		if str(k) == "focus":
			sb.draw_center = false
			sb.set_border_width_all(3)
			sb.border_color = Color("ffd84a")
		th.set_stylebox(str(k), "Button", sb)
	th.set_color("font_color", "Button", Color("f7f3e6"))
	var pb := StyleBoxFlat.new()
	pb.bg_color = Color(0.07, 0.1, 0.18, 0.94)
	pb.set_corner_radius_all(16)
	pb.set_border_width_all(2)
	pb.border_color = Color("38c6e8")
	th.set_stylebox("panel", "PanelContainer", pb)
	th.set_color("font_color", "Label", Color("f7f3e6"))
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("101826")
	bg.set_corner_radius_all(8)
	var fl := StyleBoxFlat.new()
	fl.bg_color = Color("7df0c0")
	fl.set_corner_radius_all(8)
	th.set_stylebox("background", "ProgressBar", bg)
	th.set_stylebox("fill", "ProgressBar", fl)
	return th

func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(96, 56)      # E5.4: touch targets of 48 px or more
	b.pressed.connect(cb)
	b.pressed.connect(_click)
	return b

func _click() -> void:
	g.sfx("click", -10.0)

func _label(text: String, size: int = 22) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _layout() -> void:
	var vs: Vector2 = get_viewport_rect().size
	var win: Vector2 = Vector2(DisplayServer.window_get_size())
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	sm = Rect2(Vector2.ZERO, vs)
	if win.x > 0.0 and win.y > 0.0 and safe.size.x > 0 and safe.size.y > 0 and OS.has_feature("mobile"):
		var k: Vector2 = vs / win
		var wp: Vector2 = Vector2(DisplayServer.window_get_position())
		var l: float = maxf(0.0, (float(safe.position.x) - wp.x) * k.x)
		var t: float = maxf(0.0, (float(safe.position.y) - wp.y) * k.y)
		var r: float = minf(vs.x, (float(safe.end.x) - wp.x) * k.x)
		var b: float = minf(vs.y, (float(safe.end.y) - wp.y) * k.y)
		if r - l > vs.x * 0.5 and b - t > vs.y * 0.5:
			sm = Rect2(l, t, r - l, b - t)
	if g.bridge != null and g.bridge.enabled and g.TestBridge.has_flag("notch"):
		sm = Rect2(70.0, 30.0, vs.x - 140.0, vs.y - 50.0)       # pretend notch for the release checklist
	menu_btn.position = Vector2(sm.end.x - 136.0, sm.position.y + 10.0)
	menu_btn.size = Vector2(124, 56)
	row.position = Vector2(sm.position.x + 12.0, sm.position.y + 10.0)
	row.size = Vector2(sm.size.x - 12.0 - 148.0, 56.0)
	var pw: float = minf(940.0, sm.size.x - 40.0)
	panel.position = Vector2(sm.position.x + (sm.size.x - pw) * 0.5, sm.position.y + 80.0)
	panel.size = Vector2(pw, sm.size.y - 100.0)
	dash_c = Vector2(sm.end.x - 96.0, sm.position.y + sm.size.y * 0.44)
	_place_mini()
	if shop_panel != null:
		var sw: float = minf(860.0, sm.size.x - 40.0)
		shop_panel.position = Vector2(sm.position.x + (sm.size.x - sw) * 0.5, sm.position.y + 24.0)
		shop_panel.size = Vector2(sw, sm.size.y - 48.0)

# ------------------------------------------------------------------ pages

func _page(holder: Control, id: String) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.visible = false
	holder.add_child(v)
	pages[id] = v
	return v

func _build_ship(holder: Control) -> void:
	var v: VBoxContainer = _page(holder, "ship")
	ship_points = _label("", 26)
	v.add_child(ship_points)
	for s: String in g.STATS:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 14)
		var name_l: Label = _label(str(g.STAT_NAMES[s]))
		name_l.custom_minimum_size = Vector2(170, 0)
		var pips := ProgressBar.new()
		pips.max_value = float(g.STAT_MAX)
		pips.step = 1.0
		pips.show_percentage = false
		pips.custom_minimum_size = Vector2(200, 22)
		pips.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pips.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var num: Label = _label("")
		num.custom_minimum_size = Vector2(60, 0)
		var b: Button = _button("Upgrade", _on_upgrade.bind(s))
		b.custom_minimum_size = Vector2(150, 56)
		h.add_child(name_l)
		h.add_child(pips)
		h.add_child(num)
		h.add_child(b)
		v.add_child(h)
		ship_rows[s] = [pips, b, num]
	v.add_child(_label("Crystals from enemies fill the level bar. Each level gives one point.", 18))

func _build_journal(holder: Control) -> void:
	var v: VBoxContainer = _page(holder, "journal")
	journal_head = _label("", 26)
	v.add_child(journal_head)
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	journal_grid = GridContainer.new()
	journal_grid.columns = 2
	journal_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journal_grid.add_theme_constant_override("h_separation", 24)
	journal_grid.add_theme_constant_override("v_separation", 8)
	sc.add_child(journal_grid)
	for i: int in g.find_defs.size():
		var l: Label = _label("", 18)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		journal_grid.add_child(l)

func _build_map(holder: Control) -> void:
	var v: VBoxContainer = _page(holder, "map")
	map_ctl = Control.new()
	map_ctl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_ctl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_ctl.draw.connect(_draw_map)
	v.add_child(map_ctl)

func _build_settings(holder: Control) -> void:
	var v: VBoxContainer = _page(holder, "settings")
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.follow_focus = true
	sc.add_child(grid)
	v.add_child(sc)
	var ids: Array[String] = ["difficulty", "aim_assist", "speed_idx", "invincible", "minimap", "shake", "rumble", "stick_size", "music", "sfx", "show_fps", "fullscreen", "erase"]
	for id: String in ids:
		if id == "fullscreen" and OS.has_feature("mobile"):
			continue
		var b: Button = _button("", _on_setting.bind(id))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(b)
		set_btns[id] = b
	pad_settings = _label("", 18)
	pad_settings.add_theme_color_override("font_color", Color("9fe8ff"))
	v.add_child(pad_settings)
	v.add_child(_label("Assists are here to use. Aim assist bends your aim toward enemies. Auto fire aims and fires for you. Game speed slows everything. Invincible stops all damage. Defeat never costs anything.", 18))

func _build_title() -> void:
	title = ColorRect.new()
	(title as ColorRect).color = Color(0.05, 0.08, 0.16, 0.72)
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(title)
	var c := CenterContainer.new()
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title.add_child(c)
	var v := VBoxContainer.new()
	v.custom_minimum_size = Vector2(860, 0)
	v.add_theme_constant_override("separation", 8)
	c.add_child(v)
	var name_l: Label = _label("TINY TAILWIND", 76)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_color_override("font_color", Color("ffd84a"))
	name_l.add_theme_color_override("font_outline_color", Color("1f3b63"))
	name_l.add_theme_constant_override("outline_size", 14)
	v.add_child(name_l)
	var ver: Label = _label("Version %s" % g.VERSION, 20)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(ver)
	var what: Label = _label("A twin-stick adventure. Fly a small ship, find 20 keepsakes and calm the warden of the keep.", 24)
	what.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(what)
	v.add_child(_label(" ", 8))
	v.add_child(_label("Keyboard: WASD moves. Mouse or arrow keys aim and fire. Space dashes. Esc opens Menu.", 18))
	v.add_child(_label("Xbox controller: left stick or D-pad moves. Right stick aims and fires. A, RB or RT dashes. View or Menu opens the Menu. In menus A chooses and B goes back.", 18))
	v.add_child(_label("Touch: left thumb moves. Right thumb aims and fires. Dash button on the right.", 18))
	v.add_child(_label("Defeat costs nothing. Assists are in Menu, then Settings.", 18))
	pad_title = _label("", 18)
	pad_title.add_theme_color_override("font_color", Color("9fe8ff"))
	v.add_child(pad_title)
	v.add_child(_label(" ", 8))
	start_btn = _button("Start", _on_start)
	start_btn.custom_minimum_size = Vector2(280, 68)
	start_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_btn.add_theme_font_size_override("font_size", 30)
	v.add_child(start_btn)

func _build_end() -> void:
	end_card = ColorRect.new()
	(end_card as ColorRect).color = Color(0.05, 0.08, 0.16, 0.8)
	end_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	end_card.visible = false
	add_child(end_card)
	var c := CenterContainer.new()
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	end_card.add_child(c)
	var v := VBoxContainer.new()
	v.custom_minimum_size = Vector2(760, 0)
	v.add_theme_constant_override("separation", 14)
	c.add_child(v)
	var h: Label = _label("The keep is calm", 56)
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_theme_color_override("font_color", Color("ffd84a"))
	v.add_child(h)
	end_label = _label("", 24)
	end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(end_label)
	var b: Button = _button("Keep exploring", close_end)
	b.custom_minimum_size = Vector2(300, 68)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(b)

# ------------------------------------------------------------------ title, end, menu

func show_title() -> void:
	_close_menu()
	title.visible = true
	menu_btn.visible = false
	start_btn.text = "Continue" if bool(g.save["started"]) else "Start"
	start_btn.grab_focus.call_deferred()

func hide_title() -> void:
	title.visible = false
	menu_btn.visible = true

func _on_start() -> void:
	g._first_input()
	hide_title()
	g.start_game()

func _on_title() -> void:
	_close_menu()
	g.to_title()

func show_end() -> void:
	_close_menu()
	var s: int = int(float(g.save["play_s"]))
	end_label.text = "You finished the Tiny Tailwind beta.\nFinds: %d of %d.   Level %d.\nTime: %d min %02d s.   Defeats: %d.\nThornhull calmed in %d s.\n\nMore of the world is on the way." % [
		(g.save["finds"] as Array).size(), g.find_defs.size(), int(g.save["level"]), s / 60, s % 60, int(g.save["defeats"]), int(float(g.save["boss_s"]))]
	end_card.visible = true
	menu_btn.visible = false
	(end_card.get_child(0).get_child(0).get_child(2) as Button).grab_focus.call_deferred()

func close_end() -> void:
	end_card.visible = false
	menu_btn.visible = true
	g.phase = g.Phase.PLAY

func toggle_menu() -> void:
	if title.visible or end_card.visible or shop_open:
		return
	if menu_open:
		_close_menu()
	elif g.phase == g.Phase.PLAY:
		menu_open = true
		g.set_paused(true)
		menu_btn.text = "Close"
		row.visible = true
		panel.visible = true
		open_tab(tab)
		(row_btns[tab] as Button).grab_focus.call_deferred()
		_release_touch()

func _close_menu() -> void:
	if menu_open:
		g.write_save()
	menu_open = false
	erase_armed = false
	g.set_paused(false)
	menu_btn.text = "Menu"
	row.visible = false
	panel.visible = false
	menu_btn.release_focus()

func open_tab(t: String) -> void:
	if not menu_open:
		toggle_menu()
		if not menu_open:
			return
	tab = t
	for k: Variant in pages.keys():
		(pages[k] as Control).visible = str(k) == t
	match t:
		"ship":
			_refresh_ship()
		"journal":
			_refresh_journal()
		"map":
			map_ctl.queue_redraw()
		"settings":
			_refresh_settings()

func _refresh_ship() -> void:
	ship_points.text = "Level %d.   Points to spend: %d" % [int(g.save["level"]), int(g.save["points"])]
	for s: String in g.STATS:
		var n: int = g.stat(s)
		var rowd: Array = ship_rows[s]
		(rowd[0] as ProgressBar).value = float(n)
		(rowd[2] as Label).text = "%d / %d" % [n, g.STAT_MAX]
		(rowd[1] as Button).disabled = int(g.save["points"]) <= 0 or n >= g.STAT_MAX
		(rowd[1] as Button).text = "Full" if n >= g.STAT_MAX else "Upgrade"

func _on_upgrade(s: String) -> void:
	g.spend_point(s)
	_refresh_ship()

func _refresh_journal() -> void:
	var have: Array = g.save["finds"]
	journal_head.text = "Finds: %d of %d" % [have.size(), g.find_defs.size()]
	for i: int in g.find_defs.size():
		var d: Dictionary = g.find_defs[i]
		var l: Label = journal_grid.get_child(i)
		if have.has(str(d["id"])):
			l.text = "%s\n    %s" % [str(d["name"]), str(d["note"])]
			l.modulate = Color.WHITE
		else:
			l.text = "???\n    Not found yet."
			l.modulate = Color(1, 1, 1, 0.55)

func _refresh_settings() -> void:
	var on: Callable = func(b: bool) -> String: return "On" if b else "Off"
	(set_btns["difficulty"] as Button).text = "Difficulty: %s" % g.DIFF_NAMES[int(g.save["difficulty"])]
	(set_btns["aim_assist"] as Button).text = "Aim assist: %s" % g.AIM_NAMES[int(g.save["aim_assist"])]
	(set_btns["minimap"] as Button).text = "Mini map: %s" % on.call(bool(g.save["minimap"]))
	(set_btns["shake"] as Button).text = "Screen shake: %s" % g.SHAKE_NAMES[int(g.save["shake"])]
	(set_btns["rumble"] as Button).text = "Rumble: %s" % on.call(bool(g.save["rumble"]))
	(set_btns["stick_size"] as Button).text = "Touch sticks: %s" % g.STICK_NAMES[int(g.save["stick_size"])]
	(set_btns["speed_idx"] as Button).text = "Game speed: %d%%" % g.SPEEDS[int(g.save["speed_idx"])]
	(set_btns["invincible"] as Button).text = "Invincible: %s" % on.call(bool(g.save["invincible"]))
	(set_btns["music"] as Button).text = "Music: %s" % on.call(bool(g.save["music"]))
	(set_btns["sfx"] as Button).text = "Sounds: %s" % on.call(bool(g.save["sfx"]))
	(set_btns["show_fps"] as Button).text = "Frame rate: %s" % on.call(bool(g.save["show_fps"]))
	if set_btns.has("fullscreen"):
		(set_btns["fullscreen"] as Button).text = "Full screen: %s" % on.call(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	(set_btns["erase"] as Button).text = "Press again to erase everything" if erase_armed else "Erase save"

func _on_setting(id: String) -> void:
	match id:
		"difficulty":
			g.save["difficulty"] = (int(g.save["difficulty"]) + 1) % 3
		"speed_idx":
			g.save["speed_idx"] = (int(g.save["speed_idx"]) + 1) % g.SPEEDS.size()
		"aim_assist":
			g.save["aim_assist"] = (int(g.save["aim_assist"]) + 1) % g.AIM_NAMES.size()
		"shake":
			g.save["shake"] = (int(g.save["shake"]) + 1) % g.SHAKE_NAMES.size()
		"stick_size":
			g.save["stick_size"] = (int(g.save["stick_size"]) + 1) % g.STICK_NAMES.size()
		"invincible", "sfx", "show_fps", "minimap", "rumble":
			g.save[id] = not bool(g.save[id])
		"music":
			g.save["music"] = not bool(g.save["music"])
			g.play_music(g.music_now)
		"fullscreen":
			var full: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)
		"erase":
			if erase_armed:
				g.erase_save()
				return
			erase_armed = true
			_refresh_settings()
			return
	erase_armed = false
	_refresh_settings()

func _draw_map() -> void:
	var sz: Vector2 = map_ctl.size
	var s: float = floorf(minf(sz.x / float(g.mw), (sz.y - 34.0) / float(g.mh)))
	var o := Vector2((sz.x - s * float(g.mw)) * 0.5, 34.0)
	map_ctl.draw_string(font, Vector2(0, 24), "%s.  Yellow: checkpoints.  Blue: doors.  Orange: Wren's Wagon.  White: you.%s" % [str(g.map["name"]), "  Map: gold dots are keepsakes, squares are caches." if g.owns("treasure_map") else ""], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("f7f3e6"))
	map_ctl.draw_rect(Rect2(o, Vector2(s * float(g.mw), s * float(g.mh))), Color(0.03, 0.04, 0.08))
	var cw: int = int(ceil(float(g.mw) / 4.0))
	var cols: Array[Color] = [Color("7fbf62"), Color("26402f"), Color("4fb4ea"), Color("101826")]
	for ty: int in g.mh:
		for tx: int in g.mw:
			if not g.seen_now.has((ty / 4) * cw + tx / 4):
				continue
			map_ctl.draw_rect(Rect2(o.x + float(tx) * s, o.y + float(ty) * s, s, s), cols[g.tiles[ty * g.mw + tx]])
	for c: Dictionary in g.checkpoints:
		var p: Vector2 = c["pos"]
		if g.seen_now.has((int(p.y / 64.0) / 4) * cw + int(p.x / 64.0) / 4):
			map_ctl.draw_circle(o + p / 64.0 * s, s * 0.7, Color("ffd84a"))
	for d: Dictionary in g.doors:
		var dp: Vector2 = d["pos"]
		if g.seen_now.has((int(dp.y / 64.0) / 4) * cw + int(dp.x / 64.0) / 4):
			map_ctl.draw_circle(o + dp / 64.0 * s, s * 0.7, Color("6fb8ff"))
	if g.shop_pos != Vector2.INF:
		map_ctl.draw_circle(o + g.shop_pos / 64.0 * s, s * 0.7, Color("ff8a5c"))
	if g.owns("treasure_map"):
		for f: Dictionary in g.open_finds:
			map_ctl.draw_circle(o + (f["pos"] as Vector2) / 64.0 * s, s * 0.6, Color("ffe066"))
		for oc: Dictionary in g.open_caches:
			map_ctl.draw_rect(Rect2(o + (oc["pos"] as Vector2) / 64.0 * s - Vector2(s, s) * 0.5, Vector2(s, s)), Color("ffb020"))
	map_ctl.draw_circle(o + g.ppos / 64.0 * s, s * 0.8, Color.WHITE)
	map_ctl.draw_arc(o + g.ppos / 64.0 * s, s * 1.4, 0.0, TAU, 16, Color.WHITE, 2.0)

# ------------------------------------------------------------------ messages

func push_message(text: String) -> void:
	if messages.size() < 5 and (messages.is_empty() or messages[-1] != text):
		messages.append(text)
		if messages.size() == 1:
			msg_t = 2.6

## Says whether the game sees a controller, so a player can tell a game problem from a device setting.
func pad_text() -> String:
	var pads: Array[int] = Input.get_connected_joypads()
	if pads.is_empty():
		return "Controller: none seen yet. Press any button on it. On a ROG Ally or other Windows handheld, set Control Mode to Gamepad in Command Center."
	var id: int = pads[0]
	var known: String = "" if Input.is_joy_known(id) else " (not a standard layout. Buttons may not match)"
	return "Controller: %s%s" % [Input.get_joy_name(id).left(48), known]

func _on_pad_changed(_device: int, _connected: bool) -> void:
	var t: String = pad_text()
	if pad_title != null:
		pad_title.text = t
	if pad_settings != null:
		pad_settings.text = t

func focus_text() -> String:
	var f: Control = get_viewport().gui_get_focus_owner()
	return (f as Button).text if f is Button else ""

func dash_hint() -> String:
	if g.touch_visible:
		return "Press the Dash button to dash."
	return "Dash: Space, right mouse button, or A, RB or RT on an Xbox controller."

# ------------------------------------------------------------------ the shop: Wren's Wagon

func _build_shop() -> void:
	shop_panel = PanelContainer.new()
	shop_panel.visible = false
	add_child(shop_panel)
	var m := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, 18)
	shop_panel.add_child(m)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	m.add_child(v)
	var head := HBoxContainer.new()
	var t: Label = _label("Wren's Wagon", 30)
	t.add_theme_color_override("font_color", Color("ffd84a"))
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.autowrap_mode = TextServer.AUTOWRAP_OFF
	shop_coins = _label("", 26)
	shop_coins.autowrap_mode = TextServer.AUTOWRAP_OFF
	shop_coins.add_theme_color_override("font_color", Color("ffd84a"))
	head.add_child(t)
	head.add_child(shop_coins)
	v.add_child(head)
	shop_info = _label("", 18)
	v.add_child(shop_info)
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.follow_focus = true
	v.add_child(sc)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	sc.add_child(list)
	for d: Dictionary in g.shop_defs:
		var id: String = str(d["id"])
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		var name_l: Label = _label("", 20)
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var price_l: Label = _label("", 20)
		price_l.custom_minimum_size = Vector2(190, 0)
		price_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		price_l.autowrap_mode = TextServer.AUTOWRAP_OFF
		var b: Button = _button("Buy", _on_buy.bind(id))
		b.custom_minimum_size = Vector2(130, 56)
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(name_l)
		row.add_child(price_l)
		row.add_child(b)
		list.add_child(row)
		shop_rows[id] = [name_l, price_l, b]
	shop_close = _button("Close", close_shop)
	shop_close.custom_minimum_size = Vector2(240, 56)
	shop_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(shop_close)

func open_shop() -> void:
	if menu_open:
		_close_menu()
	_release_touch()
	g.set_paused(true)          # after closing the Menu, which un-pauses
	shop_open = true
	shop_panel.visible = true
	menu_btn.visible = false
	shop_info.text = "Welcome! Coins come from enemies, bushes, pots, crystals, trees and hidden caches. B or Esc closes."
	_refresh_shop()
	_focus_shop(0)

func close_shop() -> void:
	if not shop_open:
		return
	shop_open = false
	shop_panel.visible = false
	menu_btn.visible = true
	g.set_paused(false)
	g.write_save()
	var f: Control = get_viewport().gui_get_focus_owner()
	if f != null:
		f.release_focus()

func _focus_shop(from: int) -> void:
	var ids: Array = shop_rows.keys()
	for n: int in ids.size():
		var b: Button = (shop_rows[ids[(from + n) % ids.size()]] as Array)[2]
		if not b.disabled:
			b.grab_focus.call_deferred()
			return
	shop_close.grab_focus.call_deferred()

func _refresh_shop() -> void:
	shop_coins.text = "Coins: %d" % int(g.save["coins"])
	for d: Dictionary in g.shop_defs:
		var id: String = str(d["id"])
		var row: Array = shop_rows[id]
		var mx: int = int(d.get("max", 1))
		var have: String = (" (%d of %d)" % [g.bought_count(id), mx]) if mx > 1 else ""
		(row[0] as Label).text = "%s%s\n    %s" % [str(d["name"]), have, str(d["note"])]
		var st: String = g.shop_state(id)
		var price: String = "%d coins" % g.shop_price(id)
		match st:
			"sold_out":
				price = "Sold out" if mx != 1 else "Owned"
			"need_dash":
				price = "Needs the dash"
			"full":
				price = "Hearts full"
		(row[1] as Label).text = price
		(row[1] as Label).modulate = Color(1, 0.55, 0.55) if st == "need_coins" else Color.WHITE
		var b: Button = row[2]
		b.disabled = st != "ok"
		b.focus_mode = Control.FOCUS_ALL if st == "ok" else Control.FOCUS_NONE

func _on_buy(id: String) -> void:
	var name: String = str((g.shop_by_id[id] as Dictionary)["name"])
	if g.buy(id):
		shop_info.text = "Bought: %s. Thank you!" % name
	else:
		shop_info.text = "You cannot buy the %s right now." % name
	_refresh_shop()
	var b: Button = (shop_rows[id] as Array)[2]
	if b.disabled:
		_focus_shop(shop_rows.keys().find(id) + 1)

# ------------------------------------------------------------------ mini map

func mini_shown() -> bool:
	return mini_base.visible

func _place_mini() -> void:
	if g.mw == 0:
		return
	mini_s = minf(220.0 / float(g.mw), 140.0 / float(g.mh))
	mini_base.size = Vector2(float(g.mw) * mini_s, float(g.mh) * mini_s)
	mini_base.position = Vector2(sm.end.x - 16.0 - mini_base.size.x, sm.position.y + 80.0)
	mini_dots.size = mini_base.size

func draw_mini_base(ci: Control) -> void:
	if g.mw == 0:
		return
	var s: float = mini_s
	ci.draw_rect(Rect2(Vector2(-4, -4), ci.size + Vector2(8, 8)), Color(0.05, 0.08, 0.16, 0.78))
	var cw: int = int(ceil(float(g.mw) / 4.0))
	var cols: Array[Color] = [Color("7fbf62"), Color(0, 0, 0, 0), Color("4fb4ea"), Color("101826")]
	for ty: int in g.mh:
		var start: int = -1
		var kind: int = -1
		for tx: int in g.mw + 1:
			var k: int = 1
			if tx < g.mw and g.seen_now.has((ty / 4) * cw + tx / 4):
				k = g.tiles[ty * g.mw + tx]
			if k != kind:
				if kind != 1 and start >= 0:
					ci.draw_rect(Rect2(float(start) * s, float(ty) * s, float(tx - start) * s, s), cols[kind])
				start = tx
				kind = k
	ci.draw_rect(Rect2(Vector2(-4, -4), ci.size + Vector2(8, 8)), Color(0.22, 0.78, 0.91, 0.6), false, 2.0)

func draw_mini_dots(ci: Control) -> void:
	if g.mw == 0:
		return
	var k: float = mini_s / 64.0
	var cw: int = int(ceil(float(g.mw) / 4.0))
	for c: Dictionary in g.checkpoints:
		var p: Vector2 = c["pos"]
		if g.seen_now.has((int(p.y / 64.0) / 4) * cw + int(p.x / 64.0) / 4):
			ci.draw_circle(p * k, 3.0, Color("ffd84a"))
	for d: Dictionary in g.doors:
		var dp: Vector2 = d["pos"]
		if g.seen_now.has((int(dp.y / 64.0) / 4) * cw + int(dp.x / 64.0) / 4):
			ci.draw_circle(dp * k, 3.5, Color("6fb8ff"))
	var vs: Vector2 = g.view_size()
	var c0: Vector2 = g.cam.get_screen_center_position()
	ci.draw_rect(Rect2((c0 - vs * 0.5) * k, vs * k), Color(1, 1, 1, 0.35), false, 1.0)
	if g.shop_pos != Vector2.INF:
		ci.draw_circle(g.shop_pos * k, 3.5, Color("ff8a5c"))
	if g.owns("treasure_map"):
		for f: Dictionary in g.open_finds:
			ci.draw_circle((f["pos"] as Vector2) * k, 2.5, Color("ffe066"))
		for oc: Dictionary in g.open_caches:
			ci.draw_rect(Rect2((oc["pos"] as Vector2) * k - Vector2(2.5, 2.5), Vector2(5, 5)), Color("ffb020"))
	ci.draw_circle(g.ppos * k, 3.5, Color.WHITE)
	ci.draw_arc(g.ppos * k, 6.0, 0.0, TAU, 12, Color(1, 1, 1, 0.8), 1.5)

func _process(delta: float) -> void:
	var show_mini: bool = bool(g.save["minimap"]) and not menu_open and not shop_open and not title.visible and not end_card.visible and g.phase != g.Phase.END and g.mw > 0
	mini_base.visible = show_mini
	if show_mini:
		if g.map_id != mini_map_id or g.seen_now.size() != mini_seen:
			mini_map_id = g.map_id
			mini_seen = g.seen_now.size()
			_place_mini()
			mini_base.queue_redraw()
		mini_dots.queue_redraw()
	if not messages.is_empty():
		msg_t -= delta
		if msg_t <= 0.0:
			messages.remove_at(0)
			msg_t = 2.6

# ------------------------------------------------------------------ touch (G5.3 with override 4: two thumbs)

func _release_touch() -> void:
	move_id = -1
	aim_id = -1
	g.touch_move = Vector2.ZERO
	g.touch_aim = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var st: InputEventScreenTouch = event
		if st.pressed:
			if g.phase != g.Phase.PLAY or g.paused or shop_open or menu_btn.get_global_rect().has_point(st.position):
				return
			if g.has_dash() and st.position.distance_squared_to(dash_c) < 64.0 * 64.0:
				g.touch_dash = true
			elif st.position.x < get_viewport_rect().size.x * 0.5:
				if move_id == -1:
					move_id = st.index
					move_o = st.position
					move_p = st.position
			elif aim_id == -1:
				aim_id = st.index
				aim_o = st.position
				aim_p = st.position
		else:
			if st.index == move_id:
				move_id = -1
				g.touch_move = Vector2.ZERO
			if st.index == aim_id:
				aim_id = -1
				g.touch_aim = Vector2.ZERO
	elif event is InputEventScreenDrag:
		var sd: InputEventScreenDrag = event
		if sd.index == move_id:
			move_p = sd.position
			g.touch_move = ((move_p - move_o) / (64.0 * _stick_k())).limit_length(1.0)
		elif sd.index == aim_id:
			aim_p = sd.position
			g.touch_aim = ((aim_p - aim_o) / (50.0 * _stick_k())).limit_length(1.0)

# ------------------------------------------------------------------ drawing

func _heart(p: Vector2, s: float, col: Color) -> void:
	draw_circle(p + Vector2(-s * 0.45, -s * 0.25), s * 0.55, col)
	draw_circle(p + Vector2(s * 0.45, -s * 0.25), s * 0.55, col)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-s * 0.95, 0), p + Vector2(s * 0.95, 0), p + Vector2(0, s)]), col)

func _text(p: Vector2, s: String, sz: int, col: Color, align: int = HORIZONTAL_ALIGNMENT_LEFT, w: float = -1.0) -> void:
	draw_string_outline(font, p, s, align, w, sz, 6, Color(0.05, 0.08, 0.16, 0.9))
	draw_string(font, p, s, align, w, sz, col)

func _draw() -> void:
	var vs: Vector2 = get_viewport_rect().size
	var ph: int = g.phase
	if ph == g.Phase.TITLE:
		return
	var o: Vector2 = sm.position + Vector2(18, 16)
	if not menu_open and ph != g.Phase.END:
		# hearts
		var hearts: int = g.max_hp() / 2
		for i: int in hearts:
			var hp_here: int = clampi(g.hp - i * 2, 0, 2)
			var c: Vector2 = o + Vector2(16.0 + float(i) * 36.0, 18.0)
			_heart(c, 17.0, Color(0.05, 0.08, 0.16, 0.9))
			_heart(c, 13.0, Color("5a2030"))
			if hp_here == 2:
				_heart(c, 13.0, Color("ff5d7a"))
			elif hp_here == 1:
				_heart(c, 7.5, Color("ff5d7a"))
		# level and crystals
		var y: float = o.y + 46.0
		_text(Vector2(o.x, y + 18.0), "Lv %d" % int(g.save["level"]), 20, Color("7df0c0"))
		draw_rect(Rect2(o.x + 62.0, y + 4.0, 144.0, 14.0), Color(0.05, 0.08, 0.16, 0.9))
		draw_rect(Rect2(o.x + 64.0, y + 6.0, 140.0 * clampf(float(g.save["xp"]) / float(g.xp_need()), 0.0, 1.0), 10.0), Color("7df0c0"))
		if int(g.save["points"]) > 0:
			_text(Vector2(o.x + 214.0, y + 18.0), "+%d" % int(g.save["points"]), 20, Color("ffd84a"))
		# dash bar
		y += 26.0
		if g.has_dash():
			_text(Vector2(o.x, y + 18.0), "Dash", 18, Color("9fe8ff"))
			draw_rect(Rect2(o.x + 62.0, y + 4.0, 144.0, 12.0), Color(0.05, 0.08, 0.16, 0.9))
			draw_rect(Rect2(o.x + 64.0, y + 6.0, 140.0 * (1.0 - clampf(g.dash_cd / g.dash_cooldown(), 0.0, 1.0)), 8.0), Color("38c6e8"))
			y += 24.0
		# find counter
		var sp := PackedVector2Array()
		for i: int in 10:
			sp.append(Vector2(o.x + 11.0, y + 13.0) + Vector2.from_angle(TAU * float(i) / 10.0 - PI / 2.0) * (11.0 if i % 2 == 0 else 5.0))
		draw_colored_polygon(sp, Color("ffe066"))
		_text(Vector2(o.x + 30.0, y + 20.0), "%d / %d" % [(g.save["finds"] as Array).size(), g.find_defs.size()], 20, Color("ffe066"))
		# coin counter
		y += 26.0
		draw_circle(Vector2(o.x + 11.0, y + 13.0), 9.0, Color("b07818"))
		draw_circle(Vector2(o.x + 11.0, y + 13.0), 7.0, Color("ffc83a"))
		draw_rect(Rect2(o.x + 9.0, y + 8.0, 4.0, 10.0), Color("fff2b0"))
		_text(Vector2(o.x + 30.0, y + 20.0), "%d" % int(g.save["coins"]), 20, Color("ffd84a"))
		if g.owns("shield"):
			draw_arc(Vector2(o.x + 120.0, y + 13.0), 9.0, 0.0, TAU, 16, Color("9fe8ff") if g.shield_ready else Color(1, 1, 1, 0.25), 3.0)
		# boss bar
		if g.boss != null and g.boss.alive and not g.boss.dormant:
			var bw: float = minf(560.0, vs.x * 0.5)
			var bx: float = (vs.x - bw) * 0.5
			var by: float = sm.end.y - 46.0
			_text(Vector2(bx, by - 8.0), "Thornhull", 20, Color("ffb0dc"), HORIZONTAL_ALIGNMENT_CENTER, bw)
			draw_rect(Rect2(bx - 3.0, by - 3.0, bw + 6.0, 22.0), Color(0.05, 0.08, 0.16, 0.9))
			draw_rect(Rect2(bx, by, bw * clampf(g.boss.hp / g.boss.max_hp, 0.0, 1.0), 16.0), Color("d85fa3"))
		_draw_touch(vs)
	# frame rate readout, off unless switched on in Settings
	if bool(g.save["show_fps"]) and not menu_open:
		_text(Vector2(sm.end.x - 262.0, sm.position.y + 46.0), "%d fps" % int(Engine.get_frames_per_second()), 18, Color("9fe8ff"), HORIZONTAL_ALIGNMENT_RIGHT, 112.0)
	# hurt flash and the low health warning at the screen edges
	if ph == g.Phase.PLAY and not menu_open:
		if g.hurt_flash > 0.0:
			draw_rect(Rect2(Vector2.ZERO, vs), Color(1.0, 0.2, 0.25, g.hurt_flash * 0.6))
		if g.hp <= 2 and g.max_hp() > 2 and not bool(g.save["invincible"]):
			var la: float = 0.16 + 0.1 * sin(g.time * 6.0)
			for i: int in 3:
				var w: float = 14.0 * float(3 - i)
				var c := Color(1.0, 0.15, 0.25, la * 0.7)
				draw_rect(Rect2(0, 0, vs.x, w), c)
				draw_rect(Rect2(0, vs.y - w, vs.x, w), c)
				draw_rect(Rect2(0, 0, w, vs.y), c)
				draw_rect(Rect2(vs.x - w, 0, w, vs.y), c)
	# messages sit about one third of the way down (G4.3)
	if not messages.is_empty() and not menu_open:
		var a: float = clampf(msg_t / 0.3, 0.0, 1.0) * clampf((2.6 - msg_t) / 0.15, 0.0, 1.0)
		var w: float = font.get_string_size(messages[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 48.0
		var r := Rect2((vs.x - w) * 0.5, vs.y * 0.3 - 30.0, w, 46.0)
		var sb := Color(0.05, 0.08, 0.16, 0.82 * a)
		draw_rect(r, sb)
		draw_circle(Vector2(r.position.x, r.position.y + 23.0), 23.0, sb)
		draw_circle(Vector2(r.end.x, r.position.y + 23.0), 23.0, sb)
		draw_string(font, Vector2(r.position.x, r.position.y + 31.0), messages[0], HORIZONTAL_ALIGNMENT_CENTER, w, 24, Color(1, 0.97, 0.85, a))
	if ph == g.Phase.DEFEAT:
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0.05, 0.08, 0.16, clampf(g.phase_t / 1.2, 0.0, 0.8)))
		_text(Vector2(0, vs.y * 0.45), "Back to the last checkpoint", 40, Color("ffd84a"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
		_text(Vector2(0, vs.y * 0.45 + 44.0), "Nothing is lost.", 24, Color("f7f3e6"), HORIZONTAL_ALIGNMENT_CENTER, vs.x)
	elif ph == g.Phase.FADE_OUT:
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0.03, 0.04, 0.08, clampf(g.phase_t / 0.25, 0.0, 1.0)))
	elif ph == g.Phase.FADE_IN:
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0.03, 0.04, 0.08, 1.0 - clampf(g.phase_t / 0.25, 0.0, 1.0)))

func _stick_k() -> float:
	return g.STICK_K[int(g.save["stick_size"])]

func _draw_touch(vs: Vector2) -> void:
	if not g.touch_visible or g.phase != g.Phase.PLAY:
		return
	var ring := Color(1, 1, 1, 0.28)
	var mo: Vector2 = move_o if move_id != -1 else Vector2(sm.position.x + 150.0, sm.end.y - 150.0)
	var ao: Vector2 = aim_o if aim_id != -1 else Vector2(sm.end.x - 190.0, sm.end.y - 150.0)
	var sk: float = _stick_k()
	draw_arc(mo, 64.0 * sk, 0.0, TAU, 32, ring, 4.0)
	draw_circle(mo + g.touch_move * 64.0 * sk, 28.0 * sk, Color(1, 1, 1, 0.35))
	draw_arc(ao, 64.0 * sk, 0.0, TAU, 32, Color(1.0, 0.85, 0.3, 0.4), 4.0)
	draw_circle(ao + g.touch_aim * 50.0 * sk, 28.0 * sk, Color(1.0, 0.85, 0.3, 0.45))
	if g.has_dash():
		var ready: bool = g.dash_cd <= 0.0
		draw_circle(dash_c, 46.0, Color(0.22, 0.78, 0.91, 0.5 if ready else 0.2))
		draw_arc(dash_c, 46.0, 0.0, TAU, 32, Color(1, 1, 1, 0.6), 3.0)
		draw_string(font, dash_c + Vector2(-46, 8), "Dash", HORIZONTAL_ALIGNMENT_CENTER, 92.0, 22, Color.WHITE)
