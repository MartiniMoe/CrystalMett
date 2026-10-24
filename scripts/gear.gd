extends RigidBody2D

var flying = true
var fly_time = 4
var fly_timer = 0

func _ready():
	collision_mask = 2
	collision_layer = 2

func _physics_process(delta):
	if flying:
		fly_timer += delta
		apply_central_impulse(Vector2(0, 0.5))
		angular_velocity = -0.2
		if fly_timer > fly_time:
			linear_velocity = Vector2(0, 0)
			angular_velocity = 0
			collision_mask = 1
			collision_layer = 1
			flying = false
			lock_rotation = true
			rotation = 0
			$AnimationPlayer.play("land")
			fly_timer = 0
