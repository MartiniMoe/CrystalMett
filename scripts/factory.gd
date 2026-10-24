extends StaticBody2D

signal pollute(id)

var team = 0

var processing = false
var process_timer = 0
var process_time = 2

var gear_missing = false

var points_normal = 1
var points_bernschwein = 3

const team_colors = [Color(1, 0, 0, 1), Color(0, 1, 0, 1), Color(0, 0, 1, 1), Color(1, 1, 0, 1)]

const gear = preload("res://scenes/gear.tscn")

func _ready():
	add_to_group("factory")
	add_to_group("zsort")

func _physics_process(delta):
	if processing:
		process_timer += delta
		if !$smoke.emitting:
			$smoke.emitting = true
		if process_timer > process_time:
			process_timer = 0
			processing = false
			$smoke.emitting = false
			$AnimationPlayer.stop()

# Factory_UL -> GUI/Score_UL etc.
func add_score(points):
	var score = get_node("../GUI/Score_" + name.trim_prefix("Factory_"))
	score.get_node("score").text = str(int(score.get_node("score").text) + points)
	score.get_node("AnimationPlayer").play("score")

func process_pig(pig_type):
	processing = true
	process_timer = 0
	if pig_type == "normal":
		process_time = 2
		$AnimationPlayer.play("Processing")
		add_score(points_normal)
		pollute.emit(name)
	elif pig_type == "dynamite":
		processing = false
		process_time = 0
		$AnimationPlayer.play("Exploding")
		var new_gear = gear.instantiate()
		new_gear.position = position
		new_gear.linear_velocity = -position.normalized()*200
		get_parent().add_child(new_gear)
		gear_missing = true
	elif pig_type == "bernschwein":
		process_time = 4
		$AnimationPlayer.play("Processing")
		add_score(points_bernschwein)
		for i in range(4):
			pollute.emit(name)

func colorize():
	$Sprite/shirt.self_modulate = team_colors[team]
