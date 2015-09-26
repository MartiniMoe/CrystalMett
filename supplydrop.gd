extends RigidBody2D

var fly_timer = 0
var fly_time = 2
var flying = true

func _ready():
	get_node("AnimationPlayer").play("fly")
	set_linear_velocity(vec2(0, 40))
	set_fixed_process(true)
	
func _fixed_process(delta):
	if flying:
		fly_timer += delta
		if fly_timer > fly_time:
			get_node("AnimationPlayer").play("land")
			flying = false
			set_linear_velocity(vec2(0, 0))