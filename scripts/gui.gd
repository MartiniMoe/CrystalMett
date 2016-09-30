signal restart_game()
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	pass

func restart():
	emit_signal("restart_game")

