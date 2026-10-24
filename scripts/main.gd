extends Node2D

const GS_WAIT_FOR_PLAYERS = 0
const GS_RUNNING = 1
const GS_PAUSE = 2
const GS_GAME_OVER = 3
const GS_RESTART = 4

var scoregoal = 20

var game_state = 0
var prev_game_state = 0
var next_game_state = GS_WAIT_FOR_PLAYERS

var time_elapsed = 0
var pig_spawn_delay = 5
var pig_spawn_time = 0

var supply_spawn_delay = 20
var supply_spawn_time = 0

var menu_pause = null

const pig = preload("res://scenes/pig.tscn")
const supply = preload("res://scenes/supplydrop.tscn")

var pl_player = preload("res://scenes/player.tscn")

const colarray = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1), Color(1, 1, 0)]

var state_time_elapsed = 0

var debounce = .25
var last_team_assigend = -1

var timeout_time = 30 #In Seconds
var time_remaining = timeout_time

var countdown_started = false


func new_game():
	menu_pause = $GUI/Menu_Pause

	$Factory_LL.team = 0
	$Factory_LR.team = 1
	$Factory_UL.team = 2
	$Factory_UR.team = 3

	$GUI/Score_LL/score.text = "0"
	$GUI/Score_LR/score.text = "0"
	$GUI/Score_UL/score.text = "0"
	$GUI/Score_UR/score.text = "0"

	$Factory_LL.colorize()
	$Factory_LR.colorize()
	$Factory_UL.colorize()
	$Factory_UR.colorize()

	next_game_state = GS_WAIT_FOR_PLAYERS

func _ready():
	new_game()
	$GUI.restart_game.connect(_on_GUI_restart_game)

	$StreamPlayer.stream.loop = true
	$StreamPlayer.play()

	if DisplayServer.is_touchscreen_available():
		$GUI/Menu_Join_Game/Countdown.text = "TAP YOUR CORNER TO JOIN"
		$GUI/Menu_Pause/L_Pause1.text = "PRESS BACK TO CONTINUE"

	if controls.smoke_test:
		timeout_time = 2
		time_remaining = timeout_time
		pig_spawn_delay = 1
		supply_spawn_delay = 2

func _process(delta):

	#State Machine:
	prev_game_state = game_state
	game_state = next_game_state

	if (prev_game_state != game_state):
		state_time_elapsed = 0
	state_time_elapsed += delta

	if (game_state == GS_WAIT_FOR_PLAYERS):
		gs_waitforplayers(delta)
	elif (game_state == GS_RUNNING):
		gs_running(delta)
	elif (game_state == GS_GAME_OVER):
		gs_game_over(delta)
	elif (game_state == GS_PAUSE):
		gs_pause(delta)

	#Z-Sorting:
	for obj in get_children():
		if obj.is_in_group("zsort"):
			obj.z_index = int(obj.position.y + get_viewport_rect().size.y)

func gs_waitforplayers(delta):
	if (prev_game_state == GS_WAIT_FOR_PLAYERS):
		time_elapsed += delta
	next_game_state = GS_WAIT_FOR_PLAYERS

	#Start countdown after two Players have joined the game:
	if ($Players.get_child_count() >= 2):
		if (!countdown_started):
			time_elapsed = 0
			countdown_started = true
			time_remaining = timeout_time - time_elapsed
		else:
			time_remaining -= delta

	if (time_remaining <= 0):
		time_elapsed = 0 #Reset Timer
		next_game_state = GS_RUNNING
		print("Game started with %d players" % $Players.get_child_count())
		$GUI/Menu_Join_Game/Countdown.hide()
	elif (countdown_started):
		var m = int(time_remaining / 60)
		var s = int(time_remaining) % 60
		$GUI/Menu_Join_Game/Countdown.text = "%d:%02d" % [m, s]

	for device in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(device, JOY_BUTTON_A):
			join_player(device)

	for pad in range(controls.PAD_COUNT):
		if controls.is_pad_pressed(pad):
			join_player(controls.FIRST_PAD + pad)

func join_player(i):
	var player_name = cytrill.get_player_name(i).validate_node_name()
	if (!$Players.has_node(player_name)):
		print(player_name + " has joined the game!")
		var player = pl_player.instantiate()
		player.name = player_name
		player.player_number = i
		last_team_assigend += 1
		if (last_team_assigend > 3):
			last_team_assigend = 0
		player.team = last_team_assigend
		$Players.add_child(player)
		player.init_player()
		cytrill.set_led(i, 0, colarray[player.team].r*255, colarray[player.team].g*255, colarray[player.team].b*255, 1)
		cytrill.set_led(i, 1, 0, 0, 0, 0)


func gs_running(delta):
	if (prev_game_state == GS_RUNNING):
		time_elapsed += delta

	if (state_time_elapsed > debounce && Input.is_action_pressed("pause_game")):
		next_game_state = GS_PAUSE

	var score_ul = int($GUI/Score_UL/score.text)
	var score_ur = int($GUI/Score_UR/score.text)
	var score_ll = int($GUI/Score_LL/score.text)
	var score_lr = int($GUI/Score_LR/score.text)

	var winning_player = ""
	if (score_ul >= scoregoal):
		winning_player = "UPPER LEFT"
	elif (score_ur >= scoregoal):
		winning_player = "UPPER RIGHT"
	elif (score_ll >= scoregoal):
		winning_player = "LOWER LEFT"
	elif (score_lr >= scoregoal):
		winning_player = "LOWER RIGHT"

	if (winning_player != ""):
		$GUI/Menu_Victory/L_Victory.text = winning_player + " PLAYER WINS!!!"
		next_game_state = GS_GAME_OVER
		$GUI/Menu_Victory.show()

	# Spawn those chyristal pigs
	if (time_elapsed > pig_spawn_time+pig_spawn_delay):
		pig_spawn_time = time_elapsed
		var piglet = pig.instantiate()
		piglet.position = Vector2(randf_range(-100,100),randf_range(-100,100))
		add_child(piglet)
		piglet.get_node("AnimationPlayer").play("spawn")

	# Spawn suppy drops
	if (time_elapsed > supply_spawn_time+supply_spawn_delay):
		supply_spawn_time = time_elapsed
		var new_supply = supply.instantiate()
		var destination = Vector2(randf_range(-300, 300), randf_range(-200, 200)-120)
		new_supply.destination = destination
		new_supply.position = Vector2(destination.x, -800)
		add_child(new_supply)


func gs_pause(delta):
	if (prev_game_state != GS_PAUSE):
		get_tree().paused = true
		menu_pause.time_elapsed = 0
		menu_pause.show()
	elif (!get_tree().paused):
		# the pause menu resumed the game on its own
		next_game_state = GS_RUNNING
	elif (state_time_elapsed > debounce && Input.is_action_pressed("pause_game")):
		menu_pause.hide()
		get_tree().paused = false
		next_game_state = GS_RUNNING

func gs_game_over(delta):
	next_game_state = GS_GAME_OVER
	if (prev_game_state != GS_GAME_OVER):
		$GUI/Menu_Victory.show()
		get_tree().paused = true

func rotate_factory_teams():
	var teams = [0, 1, 2, 3]
	var team_num = randi()%4
	$Factory_LL.team = teams[team_num]
	teams.remove_at(team_num)
	team_num = randi()%3
	$Factory_LR.team = teams[team_num]
	teams.remove_at(team_num)
	team_num = randi()%2
	$Factory_UL.team = teams[team_num]
	teams.remove_at(team_num)
	$Factory_UR.team = teams[0]

	$Factory_LL.colorize()
	$Factory_LR.colorize()
	$Factory_UL.colorize()
	$Factory_UR.colorize()

func _on_GUI_restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
