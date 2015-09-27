extends RigidBody2D

var destination = vec2()
var flying = true
var item = null

var rnd_items = ["bernschwein", "dynamite", 
"bernschwein", "dynamite", 
"bernschwein", "dynamite", 
"colorchange"]

func _ready():
	add_to_group("supply")
	get_node("AnimationPlayer").play("fly")
	set_linear_velocity(vec2(0, 80))
	set_fixed_process(true)
	item = rnd_items[int(rand_range(0, rnd_items.size()))]
	
func _fixed_process(delta):
	if flying:
		if get_pos().y > destination.y:
			get_node("AnimationPlayer").play("land")
			get_node("Box").set_rot(0)
			flying = false
			set_linear_velocity(vec2(0, 0))
			get_node("BoxCollision").set_trigger(false)
		else:
			set_linear_velocity(vec2(0, 80))