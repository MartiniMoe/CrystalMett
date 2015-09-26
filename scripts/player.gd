extends RigidBody2D

var move_accel = 800
var move_deaccel = 800
var move_max = 200

export var joystick_number = 0
var jostick_axis_treshhold = 0.5

var pig_carry_counter = 0
var pig_max_carry = 5

var mov_x = 0
var mov_y = 0

const player_sprite_normal = preload("res://gfx/player.png")
const player_sprite_crystal = preload("res://gfx/PlayerCrystal.png")
var animPlayer = null

func _ready():
	set_fixed_process(true)
	get_node("PlayerSprite").set_texture(player_sprite_normal)
	animPlayer = get_node("AnimationPlayer")
	animPlayer.play("walk")
	
func _fixed_process(delta):
	var mv = get_linear_velocity()
	var walking = false
	
	if get_node("PlayerSprite").get_texture() == player_sprite_crystal:
		pig_carry_counter += delta
		if pig_carry_counter > pig_max_carry:
			# PIG EXPLODE
			pig_carry_counter = 0
			get_node("PlayerSprite").set_texture(player_sprite_normal)
			get_node("fire").set_emitting(false)
			get_node("explosion").set_emitting(true)
		elif pig_carry_counter > (pig_max_carry-(pig_max_carry/4)):
			get_node("fire").set_amount(128)
		elif pig_carry_counter > pig_max_carry/2:
			get_node("fire").set_amount(64)
		elif pig_carry_counter > pig_max_carry/3:
			get_node("fire").set_amount(16)
			get_node("fire").set_emitting(true)
		
	
	if (Input.is_action_pressed("down_0") || Input.get_joy_axis(joystick_number, 1) > jostick_axis_treshhold):
		walking = true
		if mv.y < move_max:
			mv.y += move_accel*delta
			mov_y = 1
	elif (Input.is_action_pressed("up_0") || Input.get_joy_axis(joystick_number, 1) < -jostick_axis_treshhold):
		walking = true
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
	
	if (Input.is_action_pressed("right_0") || Input.get_joy_axis(joystick_number, 0) > jostick_axis_treshhold):
		walking = true
		if mv.x < move_max:
			mv.x += move_accel*delta
			mov_x = 1
	elif (Input.is_action_pressed("left_0") || Input.get_joy_axis(joystick_number, 0) < -jostick_axis_treshhold):
		walking = true
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
	
	if walking:
		if !get_node("AnimationPlayer").is_playing():
			animPlayer.play("walk")
	else:
		animPlayer.stop()
	
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
				get_node("fire").set_amount(16)
			elif "factory" in o.get_groups() && get_node("PlayerSprite").get_texture() == player_sprite_crystal:
				get_node("PlayerSprite").set_texture(player_sprite_normal)
				get_node("fire").set_emitting(false)
				pig_carry_counter = 0
				o.process_pig()