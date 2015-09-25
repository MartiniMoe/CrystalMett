extends RigidBody2D

var move_accel = 800
var move_deaccel = 800
var move_max = 200
var velocity = Vector2()

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	var mv = get_linear_velocity()
	
	if (Input.is_action_pressed("right_0")):
		if mv.x < move_max:
			mv.x += move_accel*delta
	elif (Input.is_action_pressed("left_0")):
		if mv.x > -move_max:
			mv.x -= move_accel*delta
	else:
		var xv = abs(mv.x)
		xv -= move_deaccel*delta
		if xv < 0:
			xv = 0
		mv.x = sign(mv.x)*xv
		
	if (Input.is_action_pressed("down_0")):
		if mv.y < move_max:
			mv.y += move_accel*delta
	elif (Input.is_action_pressed("up_0")):
		if mv.y > -move_max:
			mv.y -= move_accel*delta
	else:
		var yv = abs(mv.y)
		yv -= move_deaccel*delta
		if yv < 0:
			yv = 0
		mv.y = sign(mv.y)*yv
	
	set_linear_velocity(mv)