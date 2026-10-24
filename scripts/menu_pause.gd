extends Node2D

var time_elapsed = 0

func _process(delta):
	time_elapsed += delta

	if (is_visible() && time_elapsed > 1.5 && Input.is_action_pressed("pause_game")):
		get_tree().paused = false
		hide()

func _on_Button_pressed():
	get_tree().paused = false
	get_parent().restart()
	hide()
