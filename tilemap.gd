
extends TileMap

# member variables here, example:
# var a=2
# var b="textvar"

var field_size = 34#int(rand_range(5, 20))

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
	"Mud01"
]

var fence_top = ""
var fence_top_left = ""
var fence_left = ""
var fence_left_bottom = ""
var fence_bottom = ""
var fence_bottom_right = ""
var fence_right = ""
var fence_right_top = ""

func _ready():
	# Initialization here
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
			
			if int(sqrt(pow(x, 2) + pow(y, 2))) == r:
				print(int(sqrt(x^2 + y^2)), " +++ ", x, " +++ ", y)
				set_cell(x, y, get_tileset().find_tile_by_name("fence_horz"))
	#set_pos(tilemap_x, tilemap_y)


