extends RigidBody2D

var flying = true
var fly_time = 4
var fly_timer = 0

func _ready():
	set_fixed_process(true)
	set_collision_mask(2)
	set_layer_mask(2)

func _fixed_process(delta):
	if flying:
		fly_timer += delta
		apply_impulse(get_pos(), vec2(0, 0.5))
		set_angular_velocity(0.2)
		if fly_timer > fly_time:
			set_linear_velocity(vec2(0,0))
			set_collision_mask(1)
			set_layer_mask(1)
			flying = false
			set_rot(0)
			get_node("AnimationPlayer").play("land")
			fly_timer = 0