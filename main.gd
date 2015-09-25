
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

const factory = preload("res://factory.scn")

func _ready():
	# Initialization here
	var fact = factory.instance()
	fact.set_pos(vec2(-300, -300))
	add_child(fact)
