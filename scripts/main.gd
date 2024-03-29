
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

var field_size = int(34 / 2)
var space_to_edge_x = 5
var space_to_edge_y = 7
var time_elapsed = 0
var pig_spawn_delay = 5
var pig_spawn_time = 0

var supply_spawn_delay = 20
var supply_spawn_time = 0

var menu_pause = null

#const factory = preload("res://factory.scn")
const pig = preload("res://scenes/pig.scn")
const supply = preload("res://scenes/supplydrop.scn")
	
var pl_player = preload("res://scenes/player.scn")

var team1 = Color(1, 0, 0, 1)
var team2 = Color(0, 1, 0, 1)
var team3 = Color(0, 0, 1, 1)
var team4 = Color(1, 1, 0, 1)

const colarray = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1), Color(1, 1, 0)]

var state_time_elapsed = 0

var debounce = .25
var last_team_assigend = -1

var timeout_time = 30 #In Seconds
var time_remaining = timeout_time

var last_player_number = 0
var countdown_started = false


func new_game():
	randomize()
	menu_pause = get_node("GUI/Menu_Pause")
	
	get_node("Factory_LL").team = 0
	get_node("Factory_LR").team = 1
	get_node("Factory_UL").team = 2
	get_node("Factory_UR").team = 3
	
	get_node("GUI/Score_LL/score").set_text("0")
	get_node("GUI/Score_LR/score").set_text("0")
	get_node("GUI/Score_UL/score").set_text("0")
	get_node("GUI/Score_UR/score").set_text("0")
	
	get_node("Factory_LL").colorize()
	get_node("Factory_LR").colorize()
	get_node("Factory_UL").colorize()
	get_node("Factory_UR").colorize()
	
	next_game_state = GS_WAIT_FOR_PLAYERS
	
func _ready():
	set_process(true)
	
	new_game()
	
	for i in range(4):
		# This is art. Bitte halten sie mindestens einen Meter Abstand!
		# Vielen Dank für ihr Verständnis,
		# die Museumsverwaltung
		var x = pow(-1, i % 2) * 64 * (field_size - space_to_edge_x)
		var y = pow(-1, (1 + i) % 3) * 37 * (field_size - space_to_edge_y)
		
		if y < 0:
			y -= 37
		
		"""var fact = factory.instance()
		
		fact.set_pos(Vector2(x, y))
		var foo = 0
		
		if i == 2:
			foo = 1
		if i == 3:
			foo = 2
		if i == 1:
			foo = 3
		if i == 0:
			foo = 0
		
		#fact.get_node("Sprite").set_frame((foo + 1) % 4)
		#fact.get_node(str((foo + 1) % 4)).set_name("smoke")
		add_child(fact)"""

func _process(delta):

	#State Machine:
	prev_game_state = game_state
	game_state = next_game_state
	
	if (prev_game_state != game_state):
		state_time_elapsed =0
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
		if ("zsort" in obj.get_groups()):
			obj.set_z(obj.get_pos().y + get_viewport_rect().size.height)
			
func gs_waitforplayers(delta):
	if (prev_game_state == GS_WAIT_FOR_PLAYERS):
		time_elapsed += delta
	next_game_state = GS_WAIT_FOR_PLAYERS
	
	#Reset countdown after two Players have joined the game:
	if (get_node("Players").get_child_count() >= 2):
		#Start countdown after two Players have joined the game:
	
		if (!countdown_started):
			time_elapsed = 0
			countdown_started = true
			time_remaining = timeout_time - time_elapsed
		else:
			time_remaining -= delta
	
	if (time_remaining <= 0):
		time_elapsed = 0 #Reset Timer
		next_game_state = GS_RUNNING
		get_node("GUI/Menu_Join_Game/Countdown").hide()
	elif (countdown_started):
		var m = floor(time_remaining / 60)
		var s = (int(floor(time_remaining)) % 60)
		get_node("GUI/Menu_Join_Game/Countdown").set_text(str(m) + ":" + str(s))
	
	for i in range(0,1024):
			if Input.is_joy_button_pressed(i, 0):
				if (!get_node("Players").has_node(cytrill.get_name(i))):
					print("Button has been presed!")
					
					print(cytrill.get_name(i) + " has joined the game!")
					var player = pl_player.instance()
					player.set_name(cytrill.get_name(i))
					player.player_number = i
					last_team_assigend+=1
					if (last_team_assigend > 3):
						last_team_assigend = 0
					player.team = last_team_assigend
					get_node("Players").add_child(player)
					player.init_player()
					cytrill.set_led(i, 0, colarray[player.team ].r*255, colarray[player.team ].g*255, colarray[player.team ].b*255, 1)
					cytrill.set_led(i, 1, 0, 0, 0, 0)
	
		
func gs_running(delta):
	if (prev_game_state == GS_RUNNING):
		time_elapsed += delta
	
	if (state_time_elapsed > debounce &&  Input.is_action_pressed("pause_game")):
		next_game_state = GS_PAUSE
		
	var score_ul = int (get_node("GUI/Score_UL/score").get_text() )
	var score_ur = int (get_node("GUI/Score_UR/score").get_text() )
	var score_ll = int (get_node("GUI/Score_LL/score").get_text() )
	var score_lr = int (get_node("GUI/Score_LR/score").get_text() )
	
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
		get_node("GUI/Menu_Victory/L_Victory").set_text(winning_player + " PLAYER WINS!!!")
		next_game_state = GS_GAME_OVER
		get_node("GUI/Menu_Victory").show()
	
	# Spawn those chyristal pigs
	if (time_elapsed > pig_spawn_time+pig_spawn_delay):
		pig_spawn_time = time_elapsed
		var piglet = pig.instance()
		piglet.get_node("AnimationPlayer").play("spawn")
		piglet.set_pos(Vector2(rand_range(-100,100),rand_range(-100,100)))
		add_child(piglet)
	
	# Spawn suppy drops
	if (time_elapsed > supply_spawn_time+supply_spawn_delay):
		supply_spawn_time = time_elapsed
		var new_supply = supply.instance()
		#var destination = Vector2(rand_range(0, get_viewport_rect().size.width), rand_range(0, get_viewport_rect().size.height))
		var destination = Vector2(rand_range(-300, 300), rand_range(-200, 200)-120)
		new_supply.destination = Vector2(destination)
		new_supply.set_pos(Vector2(destination.x, -800))
		add_child(new_supply)
		
	

	
func gs_pause(delta):
	if (prev_game_state != GS_PAUSE):
		get_tree().set_pause(true)
		menu_pause.time_elapsed = 0
		menu_pause.show()
	elif (state_time_elapsed > debounce && Input.is_action_pressed("pause_game")):
		menu_pause.hide()
		get_tree().set_pause(false)
		next_game_state = GS_RUNNING

func gs_game_over(delta):
	next_game_state = GS_GAME_OVER
	if (prev_game_state != GS_GAME_OVER):
		get_node("GUI/Menu_Victory").show()
		get_tree().set_pause(true)

func rotate_factory_teams():
	var teams = [0, 1, 2, 3]
	var team_num = randi()%4
	get_node("Factory_LL").team = teams[team_num]
	teams.remove(team_num)
	team_num = randi()%3
	get_node("Factory_LR").team = teams[team_num]
	teams.remove(team_num)
	team_num = randi()%2
	get_node("Factory_UL").team = teams[team_num]
	teams.remove(team_num)
	get_node("Factory_UR").team = teams[0]
	
	get_node("Factory_LL").colorize()
	get_node("Factory_LR").colorize()
	get_node("Factory_UL").colorize()
	get_node("Factory_UR").colorize()

func _on_GUI_restart_game():
	#new_game()
	get_tree().change_scene("res://main.scn")
