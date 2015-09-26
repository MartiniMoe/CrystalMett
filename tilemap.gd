extends TileMap

# member variables here, example:
# var a=2
# var b="textvar"

var field_size = 34

var rnd_tiles = [
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass01",
	"Grass02",
	"Grass02",
	"Grass02",
	"Grass02",
	"Grass03",
	"Grass03",
	"Grass03",
	"Grass03",
	"Stone01"
]

var fence_top = ""
var fence_top_left = ""
var fence_left = ""
var fence_left_bottom = ""
var fence_bottom = ""
var fence_bottom_right = ""
var fence_right = ""
var fence_right_top = ""

func create_hole(id):
	print("LOLOLOLOLOLO")
	print("LOLOLOLOLOLO")
	print("LOLOLOLOLOLO")
	print("LOLOLOLOLOLO")
	print("LOLOLOLOLOLO")
	print("LOLOLOLOLOLO")
	print("LOLOLOLOLOLO")
	
	randomize()
	
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
			var n = field_size / 2 - margin
			
			if abs(x) + abs(y) < n:
				var tile_type = get_cell(x + offset_x, y + offset_y - 1)
				
				if tile_type != get_tileset().find_tile_by_name("Hole01"):
					last_tile_no_hole_x = x
					last_tile_no_hole_y = y
				
				if fast_forward and tile_type != get_tileset().find_tile_by_name("Hole01"):
					set_cell(x + offset_x, y + offset_y - 1, get_tileset().find_tile_by_name("Hole01"))
					return
				elif fast_forward:
					continue
				
				if counter == selected_tile:
					if tile_type == get_tileset().find_tile_by_name("Hole01"):
						if alt_strategy == -1:
							set_cell(last_tile_no_hole_x + offset_x, last_tile_no_hole_y + offset_y - 1, get_tileset().find_tile_by_name("Hole01"))
							return
						else:
							fast_forward = true
					else:
						set_cell(x + offset_x, y + offset_y - 1, get_tileset().find_tile_by_name("Hole01"))
						return
				else:			
					counter += 1

func _ready():
	# Initialization here
	randomize()
	
	var tilemap_x = get_viewport().get_rect().pos.x / 2
	var tilemap_y = get_viewport().get_rect().pos.y / 2
	
	clear()
	
	for x in range((-1) * field_size, 1 * field_size):
		for y in range((-1) * field_size, 1 * field_size):
			var n = field_size
			var margin = 5
			
			if abs(x) + abs(y) < n:
				var cell_tile = rnd_tiles[int(rand_range(0, rnd_tiles.size()))]
				set_cell(x, y, get_tileset().find_tile_by_name(cell_tile))
			
			if abs(x) + abs(y) == n - margin and ((x >= 0 and y < 0) or (x < 0 and y >= 0)):
				set_cell(x, y, get_tileset().find_tile_by_name("fence_vert"))
			
			if abs(x) + abs(y) == n - margin and ((x >= 0 and y > 0) or (x < 0 and y <= 0)):
				set_cell(x, y - 1, get_tileset().find_tile_by_name("fence_horz"))
			
			#if x == -(n - margin) and y == -(n - margin):
			#	set_cell(x, y, get_tileset().find_tile_by_name("fence_vert"))
			
			#if x == (n - margin) and y == -(n - margin):
			#	set_cell(x, y, get_tileset().find_tile_by_name("fence_vert"))
			
			#if x == (n - margin) and y == (n - margin):
			#	set_cell(x, y, get_tileset().find_tile_by_name("fence_vert"))
			
			#if x == -(n - margin) and y == (n - margin):
			#	set_cell(x, y, get_tileset().find_tile_by_name("fence_vert"))
			
			#var center = n / 2
			var r = 7
			
			if int(sqrt(pow(x, 2) + pow(y, 2))) <= r:
				set_cell(x, y, get_tileset().find_tile_by_name("Grass01"))
	
	#set_pos(tilemap_x, tilemap_y)
	
	get_node("../Factory_UL").connect("pollute", self, "create_hole")
	get_node("../Factory_UR").connect("pollute", self, "create_hole")
	get_node("../Factory_LR").connect("pollute", self, "create_hole")
	get_node("../Factory_LL").connect("pollute", self, "create_hole")
	
	#for i in range(100):
	#	create_hole("Factory_UL")
