extends CanvasLayer

# Input helpers shared by all scenes:
# - virtual analog sticks for touchscreens: the screen is split into 4
#   quadrants, one per player. Touching a quadrant makes that player join,
#   dragging works like a joystick. Touch pads use joystick numbers starting
#   at FIRST_PAD so they never collide with real gamepads.
# - the "pause_game" action (Escape, gamepad start, Android back button)
# - a smoke test mode (--smoke-test user argument) used by CI, which lets all
#   four touch pads join and walk around on their own.

const FIRST_PAD = 1000
const PAD_COUNT = 4
const STICK_RADIUS = 80.0

# finger index -> pad number
var fingers = {}
var pad_start = []
var pad_pos = []
var pad_active = []

var smoke_test = false
var smoke_time = 0.0

var overlay = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	for i in range(PAD_COUNT):
		pad_start.push_back(Vector2())
		pad_pos.push_back(Vector2())
		pad_active.push_back(false)

	overlay = preload("res://scripts/touch_overlay.gd").new()
	add_child(overlay)

	setup_actions()

	smoke_test = "--smoke-test" in OS.get_cmdline_user_args()

func setup_actions():
	if InputMap.has_action("pause_game"):
		return
	InputMap.add_action("pause_game")
	var key = InputEventKey.new()
	key.physical_keycode = KEY_ESCAPE
	InputMap.action_add_event("pause_game", key)
	var button = InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_START
	InputMap.action_add_event("pause_game", button)

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		Input.action_press("pause_game")
		get_tree().create_timer(0.2, true).timeout.connect(func(): Input.action_release("pause_game"))

func _process(delta):
	if smoke_test:
		smoke_time += delta
		for pad in range(PAD_COUNT):
			pad_active[pad] = true
			pad_start[pad] = Vector2(200 + pad * 400, 500)
			pad_pos[pad] = pad_start[pad] + Vector2(cos(smoke_time * (pad + 1)), sin(smoke_time * (pad + 2))) * STICK_RADIUS
		overlay.queue_redraw()

func is_touch_pad(js):
	return js >= FIRST_PAD && js < FIRST_PAD + PAD_COUNT

func get_pad_at(pos):
	var size = get_viewport().get_visible_rect().size
	var pad = 0
	if pos.x >= size.x / 2:
		pad += 1
	if pos.y < size.y / 2:
		pad += 2
	# 0 = lower left, 1 = lower right, 2 = upper left, 3 = upper right
	return pad

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var pad = get_pad_at(event.position)
			if !pad_active[pad]:
				fingers[event.index] = pad
				pad_active[pad] = true
				pad_start[pad] = event.position
				pad_pos[pad] = event.position
		elif fingers.has(event.index):
			pad_active[fingers[event.index]] = false
			fingers.erase(event.index)
		overlay.queue_redraw()
	elif event is InputEventScreenDrag:
		if fingers.has(event.index):
			pad_pos[fingers[event.index]] = event.position
			overlay.queue_redraw()

func is_pad_pressed(pad):
	return pad_active[pad]

# Drop-in replacement for Input.get_joy_axis that also knows touch pads.
func get_joy_axis(js, axis):
	if !is_touch_pad(js):
		return Input.get_joy_axis(js, axis)

	var pad = js - FIRST_PAD
	if !pad_active[pad]:
		return 0.0

	var offset = pad_pos[pad] - pad_start[pad]
	if axis == JOY_AXIS_LEFT_X:
		return clamp(offset.x / STICK_RADIUS, -1.0, 1.0)
	elif axis == JOY_AXIS_LEFT_Y:
		return clamp(offset.y / STICK_RADIUS, -1.0, 1.0)
	return 0.0
