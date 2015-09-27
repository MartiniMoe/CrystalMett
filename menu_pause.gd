
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	set_process(true)
	
func _process(delta):
	if (Input.is_action_pressed("pause_game")):
		get_tree().set_pause(false)


