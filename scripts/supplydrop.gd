extends RigidBody2D

var destination = Vector2()
var flying = true
var item = null

var rnd_items = ["bernschwein", "dynamite",
"bernschwein", "dynamite",
"bernschwein", "dynamite",
"bernschwein", "dynamite", "einstein",
"bernschwein", "dynamite",
"bernschwein", "dynamite"
]

#"colorchange"

func _ready():
	collision_mask = 4
	collision_layer = 4
	add_to_group("supply")
	$AnimationPlayer.play("fly")
	linear_velocity = Vector2(0, 80)
	item = rnd_items.pick_random()

func _physics_process(delta):
	if flying:
		if position.y > destination.y:
			$AnimationPlayer.play("land")
			$Box.rotation = 0
			flying = false
			collision_mask = 1
			collision_layer = 1
			linear_velocity = Vector2(0, 0)
		else:
			linear_velocity = Vector2(0, 80)
