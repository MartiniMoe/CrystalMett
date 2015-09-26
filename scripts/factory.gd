
extends StaticBody2D

var processing = false
var process_timer = 0
var process_time = 2

func _ready():
	add_to_group("factory")
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
			

func process_pig():
	processing = true
	process_timer = 0
	get_node("AnimationPlayer").play("Processing")
	if get_name() == "Factory_UL":
		get_node("../GUI/Score_UL").set_text(str(int(get_node("../GUI/Score_UL").get_text())+1))
	elif get_name() == "Factory_UR":
		get_node("../GUI/Score_UR").set_text(str(int(get_node("../GUI/Score_UR").get_text())+1))
	elif get_name() == "Factory_LL":
		get_node("../GUI/Score_LL").set_text(str(int(get_node("../GUI/Score_LL").get_text())+1))
	elif get_name() == "Factory_UL":
		get_node("../GUI/Score_LR").set_text(str(int(get_node("../GUI/Score_LR").get_text())+1))