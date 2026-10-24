extends TileMapLayer

var field_size = 34

# Source ids in tileset.tres
const TILE_IDS = {
	"Grass01": 0,
	"Mud01": 1,
	"fence_horz": 2,
	"fence_vert": 3,
	"Grass02": 4,
	"Grass03": 5,
	"Stone01": 6,
	"Hole01": 7,
}

var rnd_tiles = []

const pl_rift = preload("res://scenes/rift.tscn")

func tile(tile_name):
	return TILE_IDS[tile_name]

func put(x, y, tile_name):
	set_cell(Vector2i(x, y), tile(tile_name), Vector2i(0, 0))

func get_tile(x, y):
	return get_cell_source_id(Vector2i(x, y))

func set_hole(x,y, factory):
	var flip_rift = randi()%2
	put(x, y, "Hole01")
	var parent = get_parent()
	var new_hole_pos = parent.to_local(to_global(map_to_local(Vector2i(x, y)))) + Vector2(-1, -8.5)
	var new_rift = pl_rift.instantiate()
	if flip_rift == 1:
		new_rift.flip_h = true
	parent.add_child(new_rift)
	var fac_pos = parent.get_node(NodePath(factory)).position
	new_rift.position = fac_pos
	var distance = fac_pos.distance_to(new_hole_pos)
	new_rift.rotation = (new_hole_pos - fac_pos).angle()
	new_rift.scale = Vector2(distance/new_rift.texture.get_width(),1)


func create_hole(id):

	if randi() % 2 == 0:
		return

	var margin = 6
	var offset_x = 0
	var offset_y = 0

	if id == "Factory_UL":
		offset_x = -(field_size / 2 - margin / 2) - 4
	elif id == "Factory_UR":
		offset_y = -(field_size / 2 - margin / 2) - 4
	elif id == "Factory_LR":
		offset_x = (field_size / 2 - margin / 2) + 4
	elif id == "Factory_LL":
		offset_y = (field_size / 2 - margin / 2) + 4

	var n = field_size / 2 - margin

	var tiles_count = 0
	var counter = 0

	for x in range((-1) * field_size / 2, 1 * field_size / 2):
		for y in range((-1) * field_size / 2, 1 * field_size / 2):
			if abs(x) + abs(y) < n:
				tiles_count += 1

	var selected_tile = randi() % tiles_count
	var alt_strategy = pow(-1, randi() % 2)

	var last_tile_no_hole_x = -1
	var last_tile_no_hole_y = -1

	var fast_forward = false

	for x in range((-1) * field_size / 2, 1 * field_size / 2):
		for y in range((-1) * field_size / 2, 1 * field_size / 2):
			if abs(x) + abs(y) < n:
				var tile_type = get_tile(x + offset_x, y + offset_y - 1)

				if tile_type != tile("Hole01"):
					last_tile_no_hole_x = x
					last_tile_no_hole_y = y

				if fast_forward and tile_type != tile("Hole01"):
					set_hole(x + offset_x, y + offset_y - 1,id)
					return
				elif fast_forward:
					continue

				if counter == selected_tile:
					if tile_type == tile("Hole01"):
						if alt_strategy == -1:
							set_hole(last_tile_no_hole_x + offset_x, last_tile_no_hole_y + offset_y - 1,id)
							return
						else:
							fast_forward = true
					else:
						set_hole(x + offset_x, y + offset_y - 1,id)
						return
				else:
					counter += 1

func _ready():
	# Same distribution as the original hand-written list
	for i in range(57):
		rnd_tiles.append("Grass01")
	for i in range(4):
		rnd_tiles.append("Grass02")
		rnd_tiles.append("Grass03")
	rnd_tiles.append("Stone01")

	# Godot 2 drew the tile texture centered at (1, 18.5) from the cell origin,
	# Godot 4 draws it centered at map_to_local().
	position += Vector2(1, 18.5) - map_to_local(Vector2i(0, 0))

	clear()

	for x in range((-1) * field_size, 1 * field_size):
		for y in range((-1) * field_size, 1 * field_size):
			var n = field_size
			var margin = 5

			if abs(x) + abs(y) < n:
				put(x, y, rnd_tiles.pick_random())

			if abs(x) + abs(y) == n - margin and ((x >= 0 and y < 0) or (x < 0 and y >= 0)):
				put(x, y, "fence_vert")

			if abs(x) + abs(y) == n - margin and ((x >= 0 and y > 0) or (x < 0 and y <= 0)):
				put(x, y - 1, "fence_horz")

			var r = 10

			if int(sqrt(pow(x, 2) + pow(y, 2))) <= r:
				put(x, y, "Grass01")

	get_node("../Factory_UL").pollute.connect(create_hole)
	get_node("../Factory_UR").pollute.connect(create_hole)
	get_node("../Factory_LR").pollute.connect(create_hole)
	get_node("../Factory_LL").pollute.connect(create_hole)
