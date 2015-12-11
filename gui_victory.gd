
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	pass




func _on_Button1_pressed():
	get_tree().set_pause(false)
	get_parent().restart()
	hide()
	
