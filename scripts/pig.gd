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
	animPlayer = $AnimationPlayer
	will_move = randi() % 2
	if will_move == 1:
		x_dir = randi() % 3
		y_dir = randi() % 3

func _physics_process(delta):
	if animPlayer.current_animation == "spawn" && animPlayer.is_playing():
		return
	direction_change_timer += delta

	var mv = linear_velocity

	if direction_change_timer > direction_change_interval:
		direction_change_timer = 0
		will_move = randi() % 2
		if will_move == 1:
			x_dir = randi() % 3
			y_dir = randi() % 3

	if will_move == 1:
		if animPlayer.current_animation != "walk":
			animPlayer.play("walk")
		if (x_dir == 0):
			if mv.x < move_max && position.x < x_max:
				mv.x += move_accel*delta
		elif (x_dir == 1):
			if mv.x > -move_max && position.x > -x_max:
				mv.x -= move_accel*delta
		else:
			var xv = abs(mv.x)
			xv -= move_deaccel*delta
			if xv < 0:
				xv = 0
			mv.x = sign(mv.x)*xv

		if (y_dir == 0):
			if mv.y < move_max && position.y < y_max:
				mv.y += move_accel*delta
		elif (y_dir == 1):
			if mv.y > -move_max && position.y > -y_max:
				mv.y -= move_accel*delta
		else:
			var yv = abs(mv.y)
			yv -= move_deaccel*delta
			if yv < 0:
				yv = 0
			mv.y = sign(mv.y)*yv
	else:
		if animPlayer.current_animation != "idle":
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
		$Sprite.frame = 1
	elif x_dir == 1 && y_dir == 2:
		# links
		$Sprite.frame = 5
	elif x_dir == 2 && y_dir == 0:
		# unten
		$Sprite.frame = 7
	elif x_dir == 2 && y_dir == 1:
		# oben
		$Sprite.frame = 3
	elif x_dir == 0 && y_dir == 0:
		# unten rechts
		$Sprite.frame = 0
	elif x_dir == 0 && y_dir == 1:
		# oben rechts
		$Sprite.frame = 2
	elif x_dir == 1 && y_dir == 0:
		# unten links
		$Sprite.frame = 7
	elif x_dir == 1 && y_dir == 1:
		# oben links
		$Sprite.frame = 4

	linear_velocity = mv
