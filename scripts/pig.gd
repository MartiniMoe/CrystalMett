extends RigidBody2D

var move_accel = 400
var move_deaccel = 400
var move_max = 70

var direction_change_interval = 2
var direction_change_timer = 0
var x_dir = 0
var y_dir = 0
var will_move = 0
var animPlayer = null

var x_max = 100
var y_max = 80

func _ready():
	add_to_group("pig")
	randomize()
	animPlayer = get_node("AnimationPlayer")
	will_move = round(rand_range(0, 1))
	if will_move == 1:
		x_dir = round(rand_range(0, 2))
		y_dir = round(rand_range(0, 2))
	set_fixed_process(true)
	
func _fixed_process(delta):
	if animPlayer.get_current_animation() == "spawn" && animPlayer.is_playing():
		return
	direction_change_timer += delta

	var mv = get_linear_velocity()
	
	if direction_change_timer > direction_change_interval:
		direction_change_timer = 0
		will_move = round(rand_range(0, 1))
		if will_move == 1:
			x_dir = randi() % 3
			y_dir = randi() % 3
	
	if will_move == 1:
		if animPlayer.get_current_animation() != "walk":
			animPlayer.play("walk")
		if (x_dir == 0):
			if mv.x < move_max && get_pos().x < x_max:
				mv.x += move_accel*delta
		elif (x_dir == 1):
			if mv.x > -move_max && get_pos().x > -x_max:
				mv.x -= move_accel*delta
		else:
			var xv = abs(mv.x)
			xv -= move_deaccel*delta
			if xv < 0:
				xv = 0
			mv.x = sign(mv.x)*xv
			
		if (y_dir == 0):
			if mv.y < move_max && get_pos().y < y_max:
				mv.y += move_accel*delta
		elif (y_dir == 1):
			if mv.y > -move_max && get_pos().y > -y_max:
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
		get_node("Sprite").set_frame(1)
	elif x_dir == 1 && y_dir == 2:
		# links
		get_node("Sprite").set_frame(5)
	elif x_dir == 2 && y_dir == 0:
		# unten
		get_node("Sprite").set_frame(7)
	elif x_dir == 2 && y_dir == 1:
		# oben
		get_node("Sprite").set_frame(3)
	elif x_dir == 0 && y_dir == 0:
		# unten rechts
		get_node("Sprite").set_frame(0)
	elif x_dir == 0 && y_dir == 1:
		# oben rechts
		get_node("Sprite").set_frame(2)
	elif x_dir == 1 && y_dir == 0:
		# unten links
		get_node("Sprite").set_frame(7)
	elif x_dir == 1 && y_dir == 1:
		# oben links
		get_node("Sprite").set_frame(4)
	
	set_linear_velocity(mv)