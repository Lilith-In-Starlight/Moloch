extends TileMap

var areas := []

func _ready():
	areas.append($Room.get_used_rect())
	areas[0].position *= 8.0
	areas[0].size *= 8.0
	var max_point :Vector2 = areas[0].position + areas[0].size
	var min_point :Vector2 = Vector2.ZERO
	print("Generating dungeon")
	print("Step 1: Generating layout of the world")
	var rooms := 0
	var generated_end_room := false
	while not generated_end_room or rooms <= 25:
		for room in get_children():
			for element in room.get_children():
				var new_room = null
				var search_new_room := true
				var connected_door
				var tries := 0
				var new_area :Rect2
				if element.is_in_group("LeftDoor") and not element.is_in_group("DontTry"):
					while search_new_room and tries < 10:
						tries += 1
						if new_room != null:
							new_room.queue_free()
						new_room = Rooms.rooms[randi()%Rooms.rooms.size()].instance()
						var results := search_for("RightDoor", new_room, room, element)
						search_new_room = results[0]
						connected_door = results[1]
						new_area = results[2]
					element.add_to_group("DontTry")
					if tries < 10:
						connected_door.remove_from_group("RightDoor")
						element.remove_from_group("LeftDoor")
				
				elif element.is_in_group("RightDoor") and not element.is_in_group("DontTry"):
					while search_new_room and tries < 10:
						tries += 1
						if new_room != null:
							new_room.queue_free()
						new_room = Rooms.rooms[randi()%Rooms.rooms.size()].instance()
						var results := search_for("LeftDoor", new_room, room, element)
						search_new_room = results[0]
						connected_door = results[1]
						new_area = results[2]
					element.add_to_group("DontTry")
					if tries < 10:
						connected_door.remove_from_group("LeftDoor")
						element.remove_from_group("RightDoor")
				
				elif element.is_in_group("UpDoor") and not element.is_in_group("DontTry"):
					var try_to_end := false
					while search_new_room and tries < 10:
						tries += 1
						if new_room != null:
							new_room.queue_free()
						if (rooms < 25 or generated_end_room):
							new_room = Rooms.rooms[randi()%Rooms.rooms.size()].instance()
						else:
							try_to_end =  true
							new_room = preload("res://Rooms/Sacrifice/End.tscn").instance()
						var results := search_for("DownDoor", new_room, room, element)
						search_new_room = results[0]
						connected_door = results[1]
						new_area = results[2]
					element.add_to_group("DontTry")
					if tries < 10:
						if try_to_end:
							generated_end_room = true
						connected_door.remove_from_group("DownDoor")
						element.remove_from_group("UpDoor")
				
				elif element.is_in_group("DownDoor") and not element.is_in_group("DontTry"):
					while search_new_room and tries < 10:
						tries += 1
						if new_room != null:
							new_room.queue_free()
						new_room = Rooms.rooms[randi()%Rooms.rooms.size()].instance()
						var results := search_for("UpDoor", new_room, room, element)
						search_new_room = results[0]
						connected_door = results[1]
						new_area = results[2]
					element.add_to_group("DontTry")
					if tries < 10:
						connected_door.remove_from_group("UpDoor")
						element.remove_from_group("DownDoor")
				if not new_area == Rect2(0,0,0,0) and tries < 10:
					rooms += 1
					new_room.position = room.position + element.position - connected_door.position
					add_child(new_room)
					connected_door.queue_free()
					element.queue_free()
					areas.append(new_area)
					var local_max := new_area.position + new_area.size
					if local_max.x > max_point.x:
						max_point.x = local_max.x
					if local_max.y > max_point.y:
						max_point.y = local_max.y
					if new_area.position.x < min_point.x:
						min_point.x = new_area.position.x
					if new_area.position.y < min_point.y:
						min_point.y = new_area.position.y
	
	print("Step 2: Sealing up unused doors")
	for door in get_tree().get_nodes_in_group("LeftDoor"):
		var door_in_map := world_to_map(door.position) + world_to_map(door.get_parent().position)
		for x in 3:
			for y in 7:
				set_cellv(door_in_map + Vector2(x, -y), 0)
	
	for door in get_tree().get_nodes_in_group("RightDoor"):
		var door_in_map := world_to_map(door.position) + world_to_map(door.get_parent().position)
		for x in 3:
			for y in 7:
				set_cellv(door_in_map + Vector2(-x-1, -y), 0)
	
	for door in get_tree().get_nodes_in_group("UpDoor"):
		var door_in_map := world_to_map(door.position) + world_to_map(door.get_parent().position)
		for x in 22:
			for y in 3:
				set_cellv(door_in_map + Vector2(x, y), 0)
				
	for door in get_tree().get_nodes_in_group("DownDoor"):
		var door_in_map := world_to_map(door.position) + world_to_map(door.get_parent().position)
		for x in 22:
			for y in 3:
				set_cellv(door_in_map + Vector2(x, -y-1), 0)
	
	print("Step 3: Cloning all elements")
	print("    - Chests")
	for chest in get_tree().get_nodes_in_group("Chest"):
		var new_chest :RigidBody2D = preload("res://Elements/Chest.tscn").instance()
		add_child(new_chest)
		new_chest.position = chest.global_position
		chest.queue_free()
	
	print("Step 4: Passing all the room data to the world TileMap")
	for room in get_children():
		if room is TileMap:
			var room_in_map := world_to_map(room.position)
			for cell in room.get_used_cells():
				set_cellv(room_in_map + cell, room.get_cellv(cell))
			room.queue_free()
	
	max_point /= 8.0
	max_point += Vector2(64, 32)
	min_point /= 8.0
	min_point -= Vector2(64, 32)
	print("Step 5: Filling empty space from", min_point, " to ", max_point)
	print("Area: ", (max_point.x - min_point.x) * (max_point.y - min_point.y))
	for x in range(min_point.x, max_point.x):
		for y in range(min_point.y, max_point.y):
			var set := true
			for a in areas:
				if a.has_point(Vector2(x, y+1)*8.0):
					set = false
					break
			if set:
				set_cell(x, y, 0)
	print("Step 6: Adding enemies")
#	var added := 0
#	for a in areas:
#		var pos :Vector2 = (a.position*8.0 + Vector2(randf(), randf())*a.size*8.0)
#		var n := preload("res://Enemies/MagicDrone.tscn").instance()
#		add_child(n)
#		n.position = pos
#		added += 1
#		print(Vector2(randf(), randf())*a.size*8.0)
#	print("Added ", added, " enemies")
	print("Generation finished!")
	

func search_for(group:String, new_room, room, element)-> Array:
	var connected_door
	var not_found := true
	var new_rect:Rect2
	for new_element in new_room.get_children():
		if new_element.is_in_group(group):
			connected_door = new_element
			not_found = false
			new_rect = new_room.get_used_rect()
			new_rect.size *= 8.0
			new_rect.position = room.position + element.position - connected_door.position
			var dont_break := false
			for i in areas:
				if new_rect.intersects(i):
					dont_break = true
					not_found = true
			if not dont_break:
				break
	return [not_found, connected_door, new_rect]
