
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var time_elapsed = 0

func _ready():
	# Initialization here
	set_process(true)
	
func _process(delta):
	time_elapsed += delta
	
	if (is_visible() && time_elapsed > .5 && Input.is_action_pressed("pause_game")):
		get_tree().set_pause(false)
		hide()
		


func _on_Button_released():
	pass # replace with function body
