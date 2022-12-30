extends Node

var all_tiles := []

var tiles_by_side := {
	"top" : {-1: [], 0: [], 1: [], 2: []},
	"bottom" : {-1: [], 0: [], 1: [], 2: []},
	"left" : {-1: [], 0: [], 1: [], 2: []},
	"right" : {-1: [], 0: [], 1: [], 2: []},
}

var tile_size := Vector2(66, 33)


func _ready():
	print("Loading all room models")
	var rooms_directory := Directory.new()
	rooms_directory.open("res://Rooms/Sacrifice")
	rooms_directory.list_dir_begin(true, true)
	
	while true:
		var room_filename := rooms_directory.get_next()
		
		if room_filename == "":
			break
			
		var room_full_path := "res://Rooms/Sacrifice/" + room_filename
		
		if room_full_path.find("Begin") == -1 and room_full_path.find("End") == -1:
			var new_tile_index = all_tiles.size()
			print(new_tile_index, ": ", room_full_path)
			
			var room_packed_scene: PackedScene = load(room_full_path)
			all_tiles.append(room_packed_scene)
			
			var room_instance = room_packed_scene.instance()
			
			tiles_by_side["left"][room_instance.left].append(new_tile_index)
			tiles_by_side["top"][room_instance.top].append(new_tile_index)
			tiles_by_side["bottom"][room_instance.bottom].append(new_tile_index)
			tiles_by_side["right"][room_instance.right].append(new_tile_index)
			
			room_instance.free()
	
