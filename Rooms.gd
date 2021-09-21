extends Node

var rooms := []


func _ready():
	print("Loading all room models")
	var dir := Directory.new()
	dir.open("res://Rooms/Sacrifice")
	dir.list_dir_begin(true, true)
	while true:
		var file := dir.get_next()
		if file != "":
			var di := "res://Rooms/Sacrifice/" + file
			if di.find("Begin") == -1 and di.find("End") == -1 and di.find("Treasure"):
				print(di)
				var c = load(di)
				rooms.append(c)
		else:
			break
	
