extends RigidBody2D

var move_accel = 400
var move_deaccel = 400
var move_max = 100
var direction_change_time = 0
var x_dir = 0
var y_dir = 0
var will_move = 0
var animPlayer = null

func _ready():
	animPlayer = get_node("AnimationPlayer")
	will_move = round(rand_range(0, 1))
	x_dir = round(rand_range(0, 2))
	y_dir = round(rand_range(0, 2))
	set_fixed_process(true)
	
func _fixed_process(delta):
	direction_change_time += delta
	randomize()

	var mv = get_linear_velocity()
	
	if direction_change_time > 2:
		direction_change_time = 0
		will_move = round(rand_range(0, 1))
		if will_move == 1:
			x_dir = round(rand_range(0, 2))
			print(x_dir)
			y_dir = round(rand_range(0, 2))
			print(y_dir)
	
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
	
	set_linear_velocity(mv)