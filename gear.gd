extends RigidBody2D

var flying = true
var fly_time = 4
var fly_timer = 0

func _ready():
	set_fixed_process(true)
	set_collision_mask(4)

func _fixed_process(delta):
	if flying:
		fly_timer += delta
		apply_impulse(get_pos(), vec2(0, 0.5))
		set_angular_velocity(0)
		set_rot(0)
		if fly_timer > fly_time:
			set_collision_mask(1)
			flying = false
			fly_timer = 0