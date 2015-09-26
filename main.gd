
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

# ???
var field_size = int(34 / 2)
var space_to_edge_x = 5
var space_to_edge_y = 7
var time_elapsed = 0
var pig_spawn_delay = 2
var pig_spawn_time = 0

const factory = preload("res://factory.scn")
const pig = preload("res://pig.scn")

func _ready():
	set_process(true)
	# Initialization here
	randomize()
	
	for i in range(4):
		# This is art. Bitte halten sie mindestens einen Meter Abstand!
		# Vielen Dank für ihr Verständnis,
		# die Museumsverwaltung
		var x = pow(-1, i % 2) * 64 * (field_size - space_to_edge_x)
		var y = pow(-1, (1 + i) % 3) * 37 * (field_size - space_to_edge_y)
		
		if y < 0:
			y -= 37
		
		var fact = factory.instance()
		
		fact.set_pos(vec2(x, y))
		var foo = 0
		
		if i == 2:
			foo = 1
		if i == 3:
			foo = 2
		if i == 1:
			foo = 3
		if i == 0:
			foo = 0
		
		fact.get_node("Sprite").set_frame((foo + 1) % 4)
		add_child(fact)

func _process(delta):
	time_elapsed += delta
	
	if (time_elapsed > pig_spawn_time+pig_spawn_delay):
		pig_spawn_time = time_elapsed
		var piglet = pig.instance()
		piglet.get_node("AnimationPlayer").play("spawn")
		
		piglet.set_pos(vec2(rand_range(-100,100),rand_range(-100,100)))
		add_child(piglet)
	