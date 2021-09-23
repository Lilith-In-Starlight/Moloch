extends TileMap
signal generated_world

var areas := []


var max_point :Vector2
var min_point :Vector2

var fill_x := 0
var fill_y := 0
var last_frame_msecs :int
var iterations := 3

func _ready():
	print("Generating dungeon")
	position = Vector2(0, 0)
	print("Step 0: Generating first room")
	var first_room :TileMap
	if Items.level == 1:
		first_room = preload("res://Rooms/Sacrifice/Begin.tscn").instance()
		add_child(first_room)
	else:
		first_room = preload("res://Rooms/Sacrifice/BeginL2.tscn").instance()
		add_child(first_room)
	areas.append(first_room.get_used_rect())
	areas[0].position *= 8.0
	areas[0].size *= 8.0
	max_point = areas[0].position + areas[0].size
	min_point = Vector2.ZERO
	print("Step 1: Generating layout of the world")
	var rooms := 0
	var generated_end_room := false
	var treasure_rooms := 0
	while not generated_end_room or rooms <= 25 or treasure_rooms < 1:
		var children := Items.shuffle_array(get_children())
		for room in children:
			var el_children = Items.shuffle_array(room.get_children())
			for element in el_children:
				var new_room = null
				var search_new_room := true
				var connected_door
				var tries := 0
				var new_area :Rect2
				var is_treasure := false
				if element.is_in_group("LeftDoor") and not element.is_in_group("DontTry"):
					var try_to_end := false
					while search_new_room and tries < 10:
						tries += 1
						if new_room != null:
							new_room.queue_free()
						if (rooms < 25 or generated_end_room):
							if treasure_rooms < 4 and Items.WorldRNG.randf()<0.05 and rooms > 12:
								is_treasure = true
								new_room = preload("res://Rooms/Sacrifice/TreasureRoom1.tscn").instance()
							else:
								new_room = Rooms.rooms[Items.WorldRNG.randi()%Rooms.rooms.size()].instance()
						else:
							try_to_end =  true
							new_room = preload("res://Rooms/Sacrifice/End2.tscn").instance()
						var results := search_for("RightDoor", new_room, room, element)
						search_new_room = results[0]
						connected_door = results[1]
						new_area = results[2]
					element.add_to_group("DontTry")
					if tries < 10:
						if try_to_end:
							generated_end_room = true
						if is_treasure:
							treasure_rooms += 1
						connected_door.remove_from_group("RightDoor")
						element.remove_from_group("LeftDoor")
				
				elif element.is_in_group("RightDoor") and not element.is_in_group("DontTry"):
					var try_to_end := false
					while search_new_room and tries < 10:
						tries += 1
						if new_room != null:
							new_room.queue_free()
						if (rooms < 25 or generated_end_room):
							if treasure_rooms < 4 and Items.WorldRNG.randf()<0.05 and rooms > 12:
								is_treasure = true
								new_room = preload("res://Rooms/Sacrifice/TreasureRoom1.tscn").instance()
							else:
								new_room = Rooms.rooms[Items.WorldRNG.randi()%Rooms.rooms.size()].instance()
						else:
							try_to_end =  true
							new_room = preload("res://Rooms/Sacrifice/End2.tscn").instance()
						var results := search_for("LeftDoor", new_room, room, element)
						search_new_room = results[0]
						connected_door = results[1]
						new_area = results[2]
					element.add_to_group("DontTry")
					if tries < 10:
						if try_to_end:
							generated_end_room = true
						if is_treasure:
							treasure_rooms += 1
						connected_door.remove_from_group("LeftDoor")
						element.remove_from_group("RightDoor")
				
				elif element.is_in_group("UpDoor") and not element.is_in_group("DontTry"):
					var try_to_end := false
					while search_new_room and tries < 10:
						tries += 1
						if new_room != null:
							new_room.queue_free()
						if (rooms < 25 or generated_end_room):
							new_room = Rooms.rooms[Items.WorldRNG.randi()%Rooms.rooms.size()].instance()
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
						new_room = Rooms.rooms[Items.WorldRNG.randi()%Rooms.rooms.size()].instance()
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
	print("    - Platforms")
	for plat in get_tree().get_nodes_in_group("Platform"):
		var new_plat:Node2D = preload("res://Elements/Platform.tscn").instance()
		new_plat.position = plat.global_position
		new_plat.size = plat.size
		add_child(new_plat)
		plat.queue_free()
	print("    - Decorations")
	for sprite in get_tree().get_nodes_in_group("DecoSprite"):
		var new_sprite := Sprite.new()
		new_sprite.position = sprite.global_position
		new_sprite.texture = sprite.texture
		new_sprite.z_index = sprite.z_index
		add_child(new_sprite)
		sprite.queue_free()
	print("    - Paintings")
	for sprite in get_tree().get_nodes_in_group("Painting"):
		var new_sprite := Sprite.new()
		new_sprite.position = sprite.global_position
		new_sprite.texture = sprite.texture
		new_sprite.z_index = -1
		add_child(new_sprite)
		sprite.queue_free()
	print("    - MolochStatue")
	for sprite in get_tree().get_nodes_in_group("MolochStatue"):
		var new_sprite := preload("res://Elements/MolochStatue.tscn").instance()
		new_sprite.position = sprite.global_position
		new_sprite.z_index = -1
		add_child(new_sprite)
		sprite.queue_free()
	print("    - Elevator Door")
	for sprite in get_tree().get_nodes_in_group("Elevator"):
		var new_sprite := preload("res://Elements/ElevatorDoor.tscn").instance()
		new_sprite.position = sprite.global_position
		new_sprite.z_index = -1
		new_sprite.came_from = sprite.came_from
		add_child(new_sprite)
		sprite.queue_free()
	print("    - Air Conditioning Units")
	for sprite in get_tree().get_nodes_in_group("AC"):
		var new_sprite := preload("res://Elements/AC.tscn").instance()
		new_sprite.position = sprite.global_position
		new_sprite.z_index = -1
		add_child(new_sprite)
		sprite.queue_free()
	
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
	fill_x = min_point.x
	fill_y = min_point.y
	print("Step 5: Filling empty space from", min_point, " to ", max_point)
	print("Area: ", (max_point.x - min_point.x) * (max_point.y - min_point.y))
	fill_empty_space()

func _process(delta):
	if fill_x >= max_point.x:
		update_bitmask_region(min_point, max_point)
		print("Step 5: Adding enemies")
		var added := 0
		for a in areas:
			for i in Items.WorldRNG.randi()%3:
				if Items.WorldRNG.randf()<0.6:
					var pos :Vector2 = (a.position + Vector2(Items.WorldRNG.randf(), Items.WorldRNG.randf())*a.size)
					var n := preload("res://Enemies/MagicDrone.tscn").instance()
					n.position = pos
					add_child(n)
					added += 1
				if Items.WorldRNG.randf()<0.3:
					var pos :Vector2 = (a.position + Vector2(Items.WorldRNG.randf(), Items.WorldRNG.randf())*a.size)
					var n := preload("res://Enemies/SpellMachine.tscn").instance()
					n.position = pos
					add_child(n)
					added += 1
		print("Added ", added, " enemies")
		emit_signal("generated_world")
		if Items.level == 1:
			Items.run_start_time = OS.get_ticks_msec()
		print("Finished generation!")
		set_process(false)
	else:
		fill_empty_space()
		

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

func fill_empty_space():
	var start := OS.get_ticks_msec()
	var i := 0
	while fill_x < max_point.x:
		while fill_y < max_point.y:
			var set := true
			for a in areas:
				if a.has_point(Vector2(fill_x, fill_y)*8.0):
					set = false
					break
			if set:
				set_cell(fill_x, fill_y, 0)
			fill_y += 1
		if fill_y >= max_point.y:
			fill_y = min_point.y
			fill_x += 1
			i += 1
		if i > iterations:
			var msec :int = OS.get_ticks_msec() - start
			if msec > 200:
				iterations -= 1
				if iterations <= 0:
					iterations = 1
			elif msec < 200:
				iterations += 1
			break
