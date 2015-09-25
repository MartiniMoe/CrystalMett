extends RigidBody2D

var move_accel = 400
var move_deaccel = 400
var move_max = 100

var direction_change_interval = 2
var direction_change_timer = 0
var x_dir = 0
var y_dir = 0
var will_move = 0
var animPlayer = null

var sprite_r = null
var sprite_l = null
var sprite_o = null
var sprite_u = null
var sprite_ur = null
var sprite_ul = null
var sprite_or = null
var sprite_ol = null

func _ready():
	sprite_r = preload("res://gfx/pig6.png")
	sprite_l = preload("res://gfx/pig5.png")
	sprite_o = preload("res://gfx/pig8.png")
	sprite_u = preload("res://gfx/pig7.png")
	sprite_ur = preload("res://gfx/pig4.png")
	sprite_ul = preload("res://gfx/pig.png")
	sprite_or = preload("res://gfx/pig3.png")
	sprite_ol = preload("res://gfx/pig2.png")
	add_to_group("pig")
	randomize()
	animPlayer = get_node("AnimationPlayer")
	will_move = round(rand_range(0, 1))
	if will_move == 1:
		x_dir = round(rand_range(0, 2))
		y_dir = round(rand_range(0, 2))
	set_fixed_process(true)
	
func _fixed_process(delta):
	randomize()
	direction_change_timer += delta

	var mv = get_linear_velocity()
	
	if direction_change_timer > direction_change_interval:
		direction_change_timer = 0
		will_move = round(rand_range(0, 1))
		if will_move == 1:
			x_dir = round(rand_range(0, 2))
			y_dir = round(rand_range(0, 2))
	
	if will_move == 1:
		if animPlayer.get_current_animation() != "walk":
			animPlayer.play("walk")
		if (x_dir == 0):
			if mv.x < move_max:
				mv.x += move_accel*delta
		elif (x_dir == 1):
			if mv.x > -move_max:
				mv.x -= move_accel*delta
		else:
			var xv = abs(mv.x)
			xv -= move_deaccel*delta
			if xv < 0:
				xv = 0
			mv.x = sign(mv.x)*xv
			
		if (y_dir == 0):
			if mv.y < move_max:
				mv.y += move_accel*delta
		elif (y_dir == 1):
			if mv.y > -move_max:
				mv.y -= move_accel*delta
		else:
			var yv = abs(mv.y)
			yv -= move_deaccel*delta
			if yv < 0:
				yv = 0
			mv.y = sign(mv.y)*yv
	else:
		if animPlayer.get_current_animation() != "idle":
			animPlayer.play("idle")
		var xv = abs(mv.x)
		xv -= move_deaccel*delta
		if xv < 0:
			xv = 0
		mv.x = sign(mv.x)*xv
		var yv = abs(mv.y)
		yv -= move_deaccel*delta
		if yv < 0:
			yv = 0
		mv.y = sign(mv.y)*yv
	
	if x_dir == 0 && y_dir == 2:
		# rechts
		get_node("Sprite").set_texture(sprite_r)
	elif x_dir == 1 && y_dir == 2:
		# links
		get_node("Sprite").set_texture(sprite_l)
	elif x_dir == 2 && y_dir == 0:
		# unten
		get_node("Sprite").set_texture(sprite_u)
	elif x_dir == 2 && y_dir == 1:
		# oben
		get_node("Sprite").set_texture(sprite_o)
	elif x_dir == 0 && y_dir == 0:
		# unten rechts
		get_node("Sprite").set_texture(sprite_ur)
	elif x_dir == 0 && y_dir == 1:
		# oben rechts
		get_node("Sprite").set_texture(sprite_or)
	elif x_dir == 1 && y_dir == 0:
		# unten links
		get_node("Sprite").set_texture(sprite_ul)
	elif x_dir == 1 && y_dir == 1:
		# oben links
		get_node("Sprite").set_texture(sprite_ol)
	
	set_linear_velocity(mv)