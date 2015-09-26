extends RigidBody2D

var move_accel = 800
var move_deaccel = 800
var move_max = 200

export var joystick_number = 0
export var team = 0
var jostick_axis_treshhold = 0.5

var pig_carry_counter = 0
var pig_max_carry = 5

var mov_x = 0
var mov_y = 0

var is_carrying = false

const player_sprite_normal = preload("res://gfx/player.png")
const player_sprite_crystal = preload("res://gfx/PlayerCrystal.png")
const player_sprite_bernschwein = preload("res://gfx/PlayerBernschwein.png")
const player_shirt_normal = preload("res://gfx/player_Shirt.png")
const player_shirt_crystal = preload("res://gfx/PlayerCrystal_Shirt.png")
const item_bernschwein = preload("res://gfx/BonusBernschwein.png")
const item_colorchange = preload("res://gfx/BonusColorchange.png")
var animPlayer = null

var team1 = Color(1, 0, 0, 1)
var team2 = Color(0, 1, 0, 1)
var team3 = Color(0, 0, 1, 1)
var team4 = Color(1, 1, 0, 1)

func _ready():
	if team == 0:
		get_node("PlayerSprite/shirt_crystal").set_modulate(team1)
	if team == 1:
		get_node("PlayerSprite/shirt_crystal").set_modulate(team2)
	if team == 2:
		get_node("PlayerSprite/shirt_crystal").set_modulate(team3)
	if team == 3:
		get_node("PlayerSprite/shirt_crystal").set_modulate(team4)

	set_fixed_process(true)
	get_node("PlayerSprite").set_texture(player_sprite_normal)
	is_carrying = false
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
			is_carrying = false
			get_node("PlayerSprite/shirt_crystal").set_texture(player_shirt_normal)
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
		get_node("PlayerSprite/shirt_crystal").set_frame(1)
	elif mov_x == 0 && mov_y == -1:
		# oben
		get_node("PlayerSprite").set_frame(4)
		get_node("PlayerSprite/shirt_crystal").set_frame(4)
	elif mov_y == 0 && mov_x == -1:
		# links
		get_node("PlayerSprite").set_frame(6)
		get_node("PlayerSprite/shirt_crystal").set_frame(6)
	elif mov_y == 0 && mov_x == 1:
		# rechts
		get_node("PlayerSprite").set_frame(2)
		get_node("PlayerSprite/shirt_crystal").set_frame(2)
	elif mov_x == -1 && mov_y == 1:
		# unten links
		get_node("PlayerSprite").set_frame(7)
		get_node("PlayerSprite/shirt_crystal").set_frame(7)
	elif mov_x == 1 && mov_y == 1:
		# unten rechts
		get_node("PlayerSprite").set_frame(0)
		get_node("PlayerSprite/shirt_crystal").set_frame(0)
	elif mov_x == -1 && mov_y == -1:
		# oben links
		get_node("PlayerSprite").set_frame(5)
		get_node("PlayerSprite/shirt_crystal").set_frame(5)
	elif mov_x == 1 && mov_y == -1:
		# oben rechts
		get_node("PlayerSprite").set_frame(3)
		get_node("PlayerSprite/shirt_crystal").set_frame(3)
	
	set_linear_velocity(mv)
	
func _integrate_forces(state):
	if state.get_contact_count() > 0:
		for x in range(state.get_contact_count()):
			var o = state.get_contact_collider_object(x)
			if "pig" in o.get_groups() && !is_carrying:
				o.queue_free()
				get_node("PlayerSprite").set_texture(player_sprite_crystal)
				is_carrying = true
				get_node("PlayerSprite/shirt_crystal").set_texture(player_shirt_crystal)
				get_node("fire").set_amount(16)
			elif "factory" in o.get_groups() && get_node("PlayerSprite").get_texture() == player_sprite_crystal:
				get_node("PlayerSprite").set_texture(player_sprite_normal)
				is_carrying = false
				get_node("PlayerSprite/shirt_crystal").set_texture(player_shirt_normal)
				get_node("fire").set_emitting(false)
				pig_carry_counter = 0
				o.process_pig("normal")
			elif "factory" in o.get_groups() && get_node("PlayerSprite").get_texture() == player_sprite_bernschwein:
				get_node("PlayerSprite").set_texture(player_sprite_normal)
				is_carrying = false
				get_node("PlayerSprite/shirt_crystal").set_texture(player_shirt_normal)
				get_node("fire").set_emitting(false)
				pig_carry_counter = 0
				o.process_pig("bernschwein")
			elif "supply" in o.get_groups() && !is_carrying:
				if o.item == "bernschwein":
					get_node("PlayerSprite").set_texture(player_sprite_bernschwein)
					is_carrying = true
					get_node("PlayerSprite/shirt_crystal").set_texture(player_shirt_crystal)
					get_node("Item").set_texture(item_bernschwein)
					get_node("AnimationPlayer").play("item")
					o.queue_free()
				elif o.item == "colorchange":
					get_node("Item").set_texture(item_colorchange)
					get_node("AnimationPlayer").play("item")
					o.queue_free()
					get_parent().rotate_factory_teams()