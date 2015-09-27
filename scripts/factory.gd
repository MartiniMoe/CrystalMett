
extends StaticBody2D

signal pollute(id)

var team = 0

var processing = false
var process_timer = 0
var process_time = 2

var gear_missing = false

var points_normal = 1
var points_bernschwein = 4

var team1 = Color(1, 0, 0, 1)
var team2 = Color(0, 1, 0, 1)
var team3 = Color(0, 0, 1, 1)
var team4 = Color(1, 1, 0, 1)

const gear = preload("res://gear.scn")

func _ready():
	add_to_group("factory")
	add_to_group("zsort")
	set_fixed_process(true)

func _fixed_process(delta):
	if processing:
		process_timer += delta
		if !get_node("smoke").is_emitting():
			get_node("smoke").set_emitting(true)
		if process_timer > process_time:
			process_timer = 0
			processing = false
			get_node("smoke").set_emitting(false)
			get_node("AnimationPlayer").stop()
			

func process_pig(pig_type):
	processing = true
	process_timer = 0
	if pig_type == "normal":
		process_time = 2
		get_node("AnimationPlayer").play("Processing")
		if get_name() == "Factory_UL":
			get_node("../GUI/Score_UL/score").set_text(str(int(get_node("../GUI/Score_UL/score").get_text())+points_normal))
			get_node("../GUI/Score_UL/AnimationPlayer").play("score")
		elif get_name() == "Factory_UR":
			get_node("../GUI/Score_UR/score").set_text(str(int(get_node("../GUI/Score_UR/score").get_text())+points_normal))
			get_node("../GUI/Score_UR/AnimationPlayer").play("score")
		elif get_name() == "Factory_LL":
			get_node("../GUI/Score_LL/score").set_text(str(int(get_node("../GUI/Score_LL/score").get_text())+points_normal))
			get_node("../GUI/Score_LL/AnimationPlayer").play("score")
		elif get_name() == "Factory_LR":
			get_node("../GUI/Score_LR/score").set_text(str(int(get_node("../GUI/Score_LR/score").get_text())+points_normal))
			get_node("../GUI/Score_LR/AnimationPlayer").play("score")
		emit_signal("pollute", get_name())
	elif pig_type == "dynamite":
		processing = false
		process_time = 0
		get_node("AnimationPlayer").play("Exploding")
		var new_gear = gear.instance()
		get_parent().add_child(new_gear)
		new_gear.set_pos(get_pos())
		new_gear.set_linear_velocity(-get_pos().normalized()*200)
		#new_gear.set_angular_velocity(3)
		gear_missing = true
	elif pig_type == "bernschwein":
		process_time = 4
		get_node("AnimationPlayer").play("Processing")
		if get_name() == "Factory_UL":
			get_node("../GUI/Score_UL/score").set_text(str(int(get_node("../GUI/Score_UL/score").get_text())+points_bernschwein))
			get_node("../GUI/Score_UL/AnimationPlayer").play("score")
		elif get_name() == "Factory_UR":
			get_node("../GUI/Score_UR/score").set_text(str(int(get_node("../GUI/Score_UR/score").get_text())+points_bernschwein))
			get_node("../GUI/Score_UR/AnimationPlayer").play("score")
		elif get_name() == "Factory_LL":
			get_node("../GUI/Score_LL/score").set_text(str(int(get_node("../GUI/Score_LL/score").get_text())+points_bernschwein))
			get_node("../GUI/Score_LL/AnimationPlayer").play("score")
		elif get_name() == "Factory_LR":
			get_node("../GUI/Score_LR/score").set_text(str(int(get_node("../GUI/Score_LR/score").get_text())+points_bernschwein))
			get_node("../GUI/Score_LR/AnimationPlayer").play("score")
		emit_signal("pollute", get_name())
		emit_signal("pollute", get_name())
		emit_signal("pollute", get_name())
		emit_signal("pollute", get_name())

func colorize():
	if team == 0:
		get_node("Sprite/shirt").set_modulate(team1)
	if team == 1:
		get_node("Sprite/shirt").set_modulate(team2)
	if team == 2:
		get_node("Sprite/shirt").set_modulate(team3)
	if team == 3:
		get_node("Sprite/shirt").set_modulate(team4)