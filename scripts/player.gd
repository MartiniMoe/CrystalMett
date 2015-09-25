extends RigidBody2D

var move_accel = 800
var move_deaccel = 800
var move_max = 200

var mov_x = 0
var mov_y = 0

const player_sprite_normal = preload("res://gfx/player.png")
const player_sprite_crystal = preload("res://gfx/PlayerCrystal.png")

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	var mv = get_linear_velocity()
	
	if (Input.is_action_pressed("down_0")):
		if mv.y < move_max:
			mv.y += move_accel*delta
			mov_y = 1
	elif (Input.is_action_pressed("up_0")):
		if mv.y > -move_max:
			mv.y -= move_accel*delta
			mov_y = -1
	else:
		mov_y = 0
		var yv = abs(mv.y)
		yv -= move_deaccel*delta
		if yv < 0:
			yv = 0
		mv.y = sign(mv.y)*yv
	
	if (Input.is_action_pressed("right_0")):
		if mv.x < move_max:
			mv.x += move_accel*delta
			mov_x = 1
	elif (Input.is_action_pressed("left_0")):
		if mv.x > -move_max:
			mv.x -= move_accel*delta
			mov_x = -1
	else:
		mov_x = 0
		var xv = abs(mv.x)
		xv -= move_deaccel*delta
		if xv < 0:
			xv = 0
		mv.x = sign(mv.x)*xv
	
	if mov_x == 0 && mov_y == 1:
		# unten
		get_node("PlayerSprite").set_frame(1)
	elif mov_x == 0 && mov_y == -1:
		# oben
		get_node("PlayerSprite").set_frame(4)
	elif mov_y == 0 && mov_x == -1:
		# links
		get_node("PlayerSprite").set_frame(6)
	elif mov_y == 0 && mov_x == 1:
		# rechts
		get_node("PlayerSprite").set_frame(2)
	elif mov_x == -1 && mov_y == 1:
		# unten links
		get_node("PlayerSprite").set_frame(7)
	elif mov_x == 1 && mov_y == 1:
		# unten rechts
		get_node("PlayerSprite").set_frame(0)
	elif mov_x == -1 && mov_y == -1:
		# oben links
		get_node("PlayerSprite").set_frame(5)
	elif mov_x == 1 && mov_y == -1:
		# oben rechts
		get_node("PlayerSprite").set_frame(3)
	
	set_linear_velocity(mv)
	
func _integrate_forces(state):
	if state.get_contact_count() > 0:
		for x in range(state.get_contact_count()):
			var o = state.get_contact_collider_object(x)
			if "pig" in o.get_groups() && get_node("PlayerSprite").get_texture() != player_sprite_crystal:
				o.queue_free()
				get_node("PlayerSprite").set_texture(player_sprite_crystal)
			elif "factory" in o.get_groups():
				get_node("PlayerSprite").set_texture(player_sprite_normal)