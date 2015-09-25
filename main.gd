
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

# ???
var field_size = int(34 / 2)
var space_to_edge_x = 5
var space_to_edge_y = 7

const factory = preload("res://factory.scn")

func _ready():
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
		add_child(fact)
