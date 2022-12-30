extends Node

var rooms := []


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
			print(room_full_path)
			var room_packed_scene = load(room_full_path)
			rooms.append(room_packed_scene)
	
