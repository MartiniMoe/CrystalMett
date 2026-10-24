extends Node2D

signal restart_game()

func restart():
	restart_game.emit()
