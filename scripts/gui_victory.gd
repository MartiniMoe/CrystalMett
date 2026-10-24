extends Node2D

func _on_Button1_pressed():
	get_tree().paused = false
	get_parent().restart()
	hide()
