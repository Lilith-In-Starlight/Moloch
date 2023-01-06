extends Node2D
signal generated_world

const LAYOUT_MAXTRIES = 10

# Need to match with scenes (not authoritative)
const DOOR_THICKNESS = 3
const LEFT_RIGHT_DOOR_HEIGHT = 7
const UP_DOWN_DOOR_LENGTH = 22

const antidirections = {
	"LeftDoor": "RightDoor",
	"RightDoor": "LeftDoor",
	"UpDoor": "DownDoor",
	"DownDoor": "UpDoor",
}

var areas := []
var doors := []


var max_point :Vector2
var min_point :Vector2

var fill_x := 0
var x_fill_step := 3
var filling_done = false

var last_frame_msecs :int

var rooms := 0
var generated_end_room := false
var treasure_rooms := 0

var level_tile := 0
var world_tile_instances := {}

class _Room:
		var scene = null
		var is_treasure :bool = false
		var is_end :bool = false
		var area :Rect2 = Rect2()
		var attachment_door


func ready():
	if Items.level > 2:
		level_tile = 1
	
	var tile_texture := preload("res://Sprites/Blocks/RedRoomBlock.png")
	if Items.level > 2:
		tile_texture = preload("res://Sprites/Blocks/BrownRoomBlock.png")
	
	print("Generating dungeon")
	position = Vector2(0, 0)
	print("Step 0: Generating first room")
	var first_room :TileMap
	if Items.level == 1:
		first_room = preload("res://Rooms/Sacrifice/Begin.tscn").instance()
	else:
		first_room = preload("res://Rooms/Sacrifice/BeginL2.tscn").instance()
	areas.append(first_room.get_used_rect())
	areas[0].position *= 8.0
	areas[0].size *= 8.0
	max_point = Vector2(3, 0)
	min_point = Vector2(-3, -8)
	print("Step 1: Generating layout of the world")
	var world_tiles := generate_world()
	
	while not are_tiles_connected(Vector2(0, 0), Vector2(0, min_point.y + 1), world_tiles):
		world_tiles = generate_world()
	
	print("Step 2: Adding tiles as nodes")
	for tile_position in world_tiles.keys():
		var new_tile: TileMap
		if world_tiles[tile_position] is String:
			if world_tiles[tile_position] == "first_room":
				new_tile = first_room
				new_tile.position = tile_position * Rooms.tile_size * 8
				add_child(new_tile)
				new_tile.tile_set.tile_set_texture(0, tile_texture)
			elif world_tiles[tile_position] == "last_room":
				new_tile = preload("res://Rooms/Sacrifice/End.tscn").instance()
				new_tile.position = tile_position * Rooms.tile_size * 8
				add_child(new_tile)
		elif world_tiles[tile_position] == -1:
			new_tile = preload("res://Rooms/Sacrifice/Empty_room.tscn").instance()
			new_tile.position = tile_position * Rooms.tile_size * 8
			add_child(new_tile)
		else:
			new_tile = Rooms.all_tiles[world_tiles[tile_position]].instance()
			new_tile.position = tile_position * Rooms.tile_size * 8
			add_child(new_tile)
		
		new_tile.add_to_group("WorldPiece")
		world_tile_instances[tile_position] = new_tile
	
	print("Step 3: Cloning all elements")
	# this can be shrunk further if one makes the game load all files at res://Elements/* at the start
	# then here one can use load(find_tscn_for_group(group)) and it will just return already loaded refs.
	print("    - Chests")
	for chest in get_tree().get_nodes_in_group("Chest"):
		replace_layout_node_with_packed_scene(chest, preload("res://Elements/Chest.tscn"))
	print("    - Platforms")
	for plat in get_tree().get_nodes_in_group("Platform"):
		replace_layout_node_with_packed_scene(plat, preload("res://Elements/Platform.tscn"))
	print("    - Decorations")
	for sprite in get_tree().get_nodes_in_group("DecoSprite"):
		clone_sprite_node(sprite)
	print("    - Paintings")
	for sprite in get_tree().get_nodes_in_group("Painting"):
		var new_sprite: Sprite = clone_sprite_node(sprite)
		new_sprite.z_index = -1
	print("    - MolochStatue")
	for sprite in get_tree().get_nodes_in_group("MolochStatue"):
		replace_layout_node_with_background_packed_scene(sprite, preload("res://Elements/MolochStatue.tscn"))
	print("    - Vases")
	for sprite in get_tree().get_nodes_in_group("Vase"):
		replace_layout_node_with_background_packed_scene(sprite, preload("res://Elements/Vase.tscn"))
	print("    - Elevator Door")
	for sprite in get_tree().get_nodes_in_group("Elevator"):
		var new_sprite : Node2D = replace_layout_node_with_background_packed_scene(sprite, preload("res://Elements/ElevatorDoor.tscn"))
		new_sprite.came_from = sprite.came_from
	print("    - Poles")
	for sprite in get_tree().get_nodes_in_group("Pole"):
		replace_layout_node_with_background_packed_scene(sprite, preload("res://Elements/Pole.tscn"))
	print("    - Air Conditioning Units")
	for sprite in get_tree().get_nodes_in_group("AC"):
		replace_layout_node_with_background_packed_scene(sprite, preload("res://Elements/AC.tscn"))
	for sprite in get_tree().get_nodes_in_group("WandMixer"):
		replace_layout_node_with_background_packed_scene(sprite, preload("res://Elements/WandMixer.tscn"))
	for sprite in get_tree().get_nodes_in_group("Shop"):
		replace_layout_node_with_background_packed_scene(sprite, preload("res://Elements/Shop.tscn"))
	
#	print("Step 4: Passing all the room data to the world TileMap")
#	for room in get_children():
#		if room is TileMap:
#			var room_in_map := world_to_map(room.position)
#			for cell in room.get_used_cells():
#				set_cellv(room_in_map + cell, level_tile)
#			room.queue_free()
	
	max_point /= 8.0
	max_point += Vector2(64, 32)
	min_point /= 8.0
	min_point -= Vector2(64, 32)
	fill_x = min_point.x
	print("Empty space filling has been commented out for testing")
	print("It will be replaced once the world generation is changed")
#	print("Step 5: Filling empty space from", min_point, " to ", max_point)
#	print("Area: ", (max_point.x - min_point.x) * (max_point.y - min_point.y))
#	if (max_point.x - min_point.x) * (max_point.y - min_point.y) > 350000:
#		get_tree().change_scene("res://Game.tscn")
#	else:
#		fill_empty_space_chunk()


func _process(delta):
	finalize_world()
	set_process(false)
#	else:
#		fill_empty_space_chunk()


#func fill_empty_space_chunk():
#	var chunk_end = min(fill_x+x_fill_step, max_point.x)
#
#	var start := OS.get_ticks_msec()
#	for x in range(fill_x, chunk_end):
#		var y := min_point.y
#		while y < max_point.y:
#			var room := is_in_room(x, y)
#			if room == Rect2(0,0,0,0):
#				set_cell(x, y, level_tile)
#			else:
#				y += room.size.y / 8 - 1
#			y += 1
#	x_fill_step = readjust_chunk_size(x_fill_step, start, OS.get_ticks_msec(), 200)
#
#	fill_x = chunk_end
#	if chunk_end == max_point.x:
#		filling_done = true

func readjust_chunk_size(chunk_size: int, start: int, end: int, desired_chunk_ms: int) -> int:
			var msec :int = end - start
			var new_size_f :float = float(desired_chunk_ms)/float(msec) * float(chunk_size)
			if new_size_f <= 1:
				new_size_f = 1
			return int(new_size_f)

func is_in_room(x: int, y: int) -> Rect2:
	for a in areas:
		if a.has_point(Vector2(x, y)*8):
			return a
	return Rect2(0,0,0,0)

func finalize_world():
	print("Autotiling has been commented out for testing")
#	print("Step 6: Autotiling so it's pretty")
#	update_bitmask_region(min_point, max_point)
	print("Step 7: Adding enemies")
	add_enemies()
#	print("Enemy generation has been commented out for testing")
	emit_signal("generated_world")
	if Config.discord != null:
		var act = Discord.Activity.new()
		act.state = "Level %s" % str(Items.level)
		act.details = "Just entered level"
		act.assets.large_image = "logoimage"
		act.assets.large_text = "Optimizing for X"
		act.timestamps.start = Config.app_start_time
		Config.discord.get_activity_manager().update_activity(act)
	if Items.level == 1:
		Items.run_start_time = OS.get_ticks_msec()
	print("Finished generation!")

func add_enemies():
	var enemies = []
	for tile in world_tile_instances:
		var area = Rect2(tile * Rooms.tile_size * 8, Rooms.tile_size * 8)
		for i in (1 + Items.WorldRNG.randi()%3):
			enemies.append(add_enemy_with_chance(area, preload("res://Enemies/MagicDrone.tscn"), 0.7))
			enemies.append(add_enemy_with_chance(area, preload("res://Enemies/SpellMachine.tscn"), 0.3))
			enemies.append(add_enemy_with_chance(area, preload("res://Enemies/Incomplete.tscn"), 0.1))
			if Items.level > 1:
				enemies.append(add_enemy_with_chance(area, preload("res://Enemies/ArmageddonMachine.tscn"), 0.001))
			if Items.level > 2 and Items.level < 5:
				enemies.append(add_enemy_with_chance(area, preload("res://Enemies/Citizen.tscn"), 0.25))
			if Items.level > 3:
				enemies.append(add_enemy_with_chance(area, preload("res://Enemies/Firemoth.tscn"), 0.3))
			if Items.level == 1:
				enemies.append(add_enemy_with_chance(area, preload("res://Enemies/SoulWaveMachine.tscn"), 0.001))
			elif Items.level == 2:
				enemies.append(add_enemy_with_chance(area, preload("res://Enemies/SoulWaveMachine.tscn"), 0.005))
			elif Items.level <= 6:
				enemies.append(add_enemy_with_chance(area, preload("res://Enemies/SoulWaveMachine.tscn"), 0.009))
			elif Items.level <= 12:
				enemies.append(add_enemy_with_chance(area, preload("res://Enemies/SoulWaveMachine.tscn"), 0.1))
			else:
				enemies.append(add_enemy_with_chance(area, preload("res://Enemies/SoulWaveMachine.tscn"), 0.2))
	remove_nulls(enemies)
	print("Added ", len(enemies), " enemies")

# Needs to be moved to utils or somewhere
func remove_nulls(array: Array):
	for i in array.count(null):
		array.erase(null)

# Also these 2 are obviously area's or room's methods
func add_enemy_with_chance(area: Rect2, packed_scene: PackedScene, chance: float) -> Node2D:
	if Items.WorldRNG.randf() < chance:
		return add_enemy(area,packed_scene)
	return null

func add_enemy(area: Rect2, packed_scene: PackedScene) -> Node2D:
	var pos :Vector2 = (area.position + Vector2(Items.WorldRNG.randf(), Items.WorldRNG.randf())*area.size)
	var node:Node2D = packed_scene.instance()
	node.position = pos
	call_deferred("add_child",node)
	return node

func expand_through_door(element, room) -> _Room:
	var res: _Room = null
	if element.is_in_group("DontTry"):
		return null

	if is_horizontal_door(element) or element.is_in_group("UpDoor"):
		for _i in range(LAYOUT_MAXTRIES):
			var r_candidate: _Room
			if rooms < 25 or generated_end_room:
				if treasure_rooms < 4 and Items.WorldRNG.randf()<0.02 and rooms > 12 \
					and is_horizontal_door(element):
						r_candidate = new_treasure_room()
				else:
					r_candidate = new_normal_room()
			else:
				var endscene
				if is_horizontal_door(element):
					endscene = preload("res://Rooms/Sacrifice/End2.tscn")
				else:
					endscene = preload("res://Rooms/Sacrifice/End.tscn")
				r_candidate = end_room_from_scene(endscene)
			if not try_dock(r_candidate, element, room):
				res = r_candidate
				break

	elif element.is_in_group("DownDoor"):
		for _i in range(LAYOUT_MAXTRIES):
			var r_candidate: _Room = new_normal_room()
			if not try_dock(r_candidate, element, room):
				res = r_candidate
				break
	
	element.add_to_group("DontTry")
	if res and not res.area == Rect2(0,0,0,0):
		doors.append(room.position + element.position)
		res.scene.position = room.position + element.position - res.attachment_door.position
		dissolve_doorpair(element, res.attachment_door)
		return res
	else:
		return null


func expand_through_door_with_treasure(element, room) -> _Room:
	var res: _Room = null
	if element.is_in_group("DontTry"):
		return null

	if is_horizontal_door(element):
		for _i in range(LAYOUT_MAXTRIES):
			var r_candidate: _Room
			r_candidate = new_treasure_room()
			if not try_dock(r_candidate, element, room):
				res = r_candidate
				break
	
	element.add_to_group("DontTry")
	if res and not res.area == Rect2(0,0,0,0):
		doors.append(room.position + element.position)
		res.scene.position = room.position + element.position - res.attachment_door.position
		dissolve_doorpair(element, res.attachment_door)
		return res
	else:
		return null

func new_normal_room() -> _Room:
	var new_room = Rooms.rooms[Items.WorldRNG.randi()%Rooms.rooms.size()].instance()
	var r :_Room = _Room.new()
	r.scene = new_room
	return r

func new_treasure_room() -> _Room:
	var r :_Room = _Room.new()
	match Items.WorldRNG.randi()%3:
		0:
			r.scene = preload("res://Rooms/Sacrifice/TreasureRoom1.tscn").instance()
		1:
			r.scene = preload("res://Rooms/Sacrifice/TreasureRoom2.tscn").instance()
		2:
			if Items.WorldRNG.randf()<0.8:
				r.scene = preload("res://Rooms/Sacrifice/TreasureRoom3.tscn").instance()
			else:
				r.scene = preload("res://Rooms/Sacrifice/TreasureRoom4.tscn").instance()
	r.is_treasure = true
	return r

func end_room_from_scene(scene) -> _Room:
	var r :_Room = _Room.new()
	r.scene = scene.instance()
	r.is_end = true
	return r

func get_doorgroup(element) -> String:
	for g in element.get_groups():
		if "Door" in g:
			return g
	return ''

func is_horizontal_door(element) -> bool:
		return (element.is_in_group("LeftDoor") or element.is_in_group("RightDoor"))

func get_door_rect(door): # see the scenes to get a feeling
	var rect = Rect2()
	if is_horizontal_door(door):
		rect.size = Vector2(DOOR_THICKNESS, LEFT_RIGHT_DOOR_HEIGHT)
		rect.position.y = -rect.size.y # left-right doors' nodes are on the floor...
		if get_doorgroup(door) == "RightDoor":
				rect.position.x = -rect.size.x # ... at the very borders the room
	else:
		rect.size = Vector2(UP_DOWN_DOOR_LENGTH, DOOR_THICKNESS)
		if get_doorgroup(door) == "DownDoor":
			rect.position.y = - rect.size.y # up-downs are at the borders, too
	return rect

func dissolve_doorpair(element, connected_door):
	var direction_doorgroup = get_doorgroup(element)
	element.remove_from_group(direction_doorgroup)
	connected_door.remove_from_group(antidirections[direction_doorgroup])
	connected_door.queue_free()
	element.queue_free()

func try_dock(new_room: _Room, element, room) -> bool:
	var direction_doorgroup: String = get_doorgroup(element)
	var search_results = search_for(antidirections[direction_doorgroup], new_room.scene, room, element)
	new_room.attachment_door = search_results[1]
	new_room.area = search_results[2]
	return search_results[0]

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

func replace_layout_node_with_scene(node, scene):
	scene.position = node.global_position
	if has_property(scene, "size"):
		scene.size = node.size
	add_child(scene)
	node.queue_free()

func replace_layout_node_with_packed_scene(node, scene: PackedScene):
	replace_layout_node_with_scene(node,scene.instance())

func replace_layout_node_with_background_packed_scene(node, scene: PackedScene):
	var unpacked = scene.instance()
	replace_layout_node_with_scene(node, unpacked)
	unpacked.z_index = -1
	return unpacked

func clone_sprite_node(sprite) -> Sprite:
	var clone = Sprite.new()
	clone.texture = sprite.texture
	clone.z_index = sprite.z_index
	replace_layout_node_with_scene(sprite, clone)
	return clone

func summon_item(item:Item, position: Vector2, speed: Vector2) -> void:
	var new_item_entity := preload("res://Items/ItemEntity.tscn").instance()
	new_item_entity.item = item
	new_item_entity.position = position
	new_item_entity.linear_velocity = speed
	add_child(new_item_entity)


func summon_spell(spell:Spell, position: Vector2, speed: Vector2) -> void:
	var new_spell_entity := preload("res://Items/SpellEntity.tscn").instance()
	new_spell_entity.spell = spell
	new_spell_entity.position = position
	new_spell_entity.linear_velocity = speed
	add_child(new_spell_entity)


func summon_wand(wand:Wand, position: Vector2, speed: Vector2) -> void:
	var new_wand_entity := preload("res://Items/WandEntity.tscn").instance()
	new_wand_entity.wand = wand
	new_wand_entity.position = position
	new_wand_entity.linear_velocity = speed
	add_child(new_wand_entity)

func summon_explosion(position, size := 10) -> void:
	var new_explosion := preload("res://Particles/Explosion.tscn").instance()
	new_explosion.area_of_effect = size
	new_explosion.position = position
	get_parent().add_child(new_explosion)

func play_sound(sound: AudioStream, position: Vector2, volume := 0.0, pitch := 1.0, bus := "Master") -> void:
	var new_audio_player := AudioStreamPlayer2D.new()
	new_audio_player.position = position
	new_audio_player.stream = sound
	new_audio_player.volume_db = volume
	new_audio_player.pitch_scale = pitch
	new_audio_player.bus = bus
	new_audio_player.autoplay = true
	add_child(new_audio_player)

func stretch_global_bounds(new_area :Rect2):
		var local_max := new_area.position + new_area.size
		if local_max.x > max_point.x:
				max_point.x = local_max.x
		if local_max.y > max_point.y:
				max_point.y = local_max.y
		if new_area.position.x < min_point.x:
				min_point.x = new_area.position.x
		if new_area.position.y < min_point.y:
				min_point.y = new_area.position.y

func fill_rect(rect: Rect2, value):
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			pass
#			set_cellv(rect.position+Vector2(x,y), value)

func has_property(object: Object, property_name: String) -> bool:
	for property in object.get_property_list():
		if property['name'] == property_name:
			return true
	return false


func get_adjacent_positions(pos: Vector2) -> Array:
	return [pos + Vector2.UP, pos + Vector2.DOWN, pos + Vector2.LEFT, pos + Vector2.RIGHT]


func get_tile_side_restrictions(tile_position: Vector2, world_tiles: Dictionary) -> Dictionary:
	var adjacent_positions := get_adjacent_positions(tile_position)
	var sides_to_consider := {}
	if world_tiles.has(adjacent_positions[0]):
		sides_to_consider["top"] = get_tile_side_value(world_tiles[adjacent_positions[0]], "bottom")
	if world_tiles.has(adjacent_positions[1]):
		sides_to_consider["bottom"] = get_tile_side_value(world_tiles[adjacent_positions[1]], "top")
	if world_tiles.has(adjacent_positions[2]):
		sides_to_consider["left"] = get_tile_side_value(world_tiles[adjacent_positions[2]], "right")
	if world_tiles.has(adjacent_positions[3]):
		sides_to_consider["right"] = get_tile_side_value(world_tiles[adjacent_positions[3]], "left")
	
	return sides_to_consider


func get_tile_side_value(tile_id, side: String) -> int:
	if tile_id is String:
		if tile_id == "first_room":
			if side == "bottom":
				return -1
			else:
				return 0
		elif tile_id == "last_room":
			if side == "top":
				return -1
			else:
				return 0
		else:
			return -1
	elif tile_id is int:
		if tile_id == -1:
			return -1
		var instance = Rooms.all_tiles[tile_id].instance()
		var output = instance.left
		if side == "right":
			output = instance.right
		elif side == "bottom":
			output = instance.bottom
		elif side == "top":
			output = instance.top
		instance.free()
		return output
	
	return -1



func get_tile_with_requirements(requirement: Dictionary) -> int:
	if requirement.empty():
		return Rooms.all_tiles[Items.WorldRNG.randi() % Rooms.all_tiles.size()]
	
	var matches_top := ["boop"]
	var matches_bottom := ["boop"]
	var matches_left := ["boop"]
	var matches_right := ["boop"]
	
	
	if requirement.has("top"):
		matches_top = Rooms.tiles_by_side["top"][requirement["top"]]
	
	if requirement.has("bottom"):
		matches_bottom = Rooms.tiles_by_side["bottom"][requirement["bottom"]]
	
	if requirement.has("left"):
		matches_left = Rooms.tiles_by_side["left"][requirement["left"]]
	
	if requirement.has("right"):
		matches_right = Rooms.tiles_by_side["right"][requirement["right"]]
	
	
	var all_side_matches = [matches_bottom, matches_top, matches_right, matches_left]
	
	
	for i in all_side_matches.duplicate():
		if not i.empty() and i[0] is String:
			all_side_matches.erase(i)
	
	var all_valid_matches := []
	
	if all_side_matches.size() > 0:
		all_valid_matches = all_side_matches[0]
		if all_side_matches.size() > 1:
			for i in range(1, all_side_matches.size()):
				all_valid_matches = intersect_sets(all_valid_matches, all_side_matches[i])
	
	if all_valid_matches.empty():
		return -1
	
	return all_valid_matches[Items.WorldRNG.randi()%all_valid_matches.size()]
	


func intersect_sets(a: Array, b: Array) -> Array:
	var starting_set = a
	var other_set = b
	var output_set := []
	if b.size() > a.size():
		starting_set = b
		other_set = a
	
	
	for element in starting_set:
		if other_set.has(element):
			output_set.append(element)
	return output_set


func generate_world() -> Dictionary:
	var world_tiles := {}
	var tiles_to_make := [Vector2(0, min_point.y + 1), Vector2.ZERO]
	var tiles_made := []
	
	while not tiles_to_make.empty():
		var tile_position :Vector2 = tiles_to_make.pop_front()
		 
		if tile_position in tiles_made:
			continue
		
		tiles_made.append(tile_position)
		
		if tile_position == Vector2(0, 0):
			world_tiles[tile_position] = "first_room"
			tiles_to_make.append_array(get_adjacent_positions(tile_position))
			continue
		
		if tile_position == Vector2(0, min_point.y + 1):
			world_tiles[tile_position] = "last_room"
			tiles_to_make.append_array(get_adjacent_positions(tile_position))
			continue
		
		if tile_position.x < min_point.x - 3 or tile_position.x > max_point.x + 3 or tile_position.y < min_point.y - 3 or tile_position.y > max_point.y + 3:
			continue
		
		tiles_to_make.append_array(get_adjacent_positions(tile_position))
		
		var sides_to_consider := get_tile_side_restrictions(tile_position, world_tiles)
		
		if tile_position.x == min_point.x:
			sides_to_consider["left"] = -1
		if tile_position.x == max_point.x:
			sides_to_consider["right"] = -1
		if tile_position.y == min_point.y:
			sides_to_consider["top"] = -1
		if tile_position.y == max_point.y:
			sides_to_consider["bottom"] = -1
		
		if tile_position.x < min_point.x:
			sides_to_consider["left"] = -1
			sides_to_consider["right"] = -1
			sides_to_consider["top"] = -1
			sides_to_consider["bottom"] = -1
		if tile_position.x > max_point.x:
			sides_to_consider["left"] = -1
			sides_to_consider["right"] = -1
			sides_to_consider["top"] = -1
			sides_to_consider["bottom"] = -1
		if tile_position.y < min_point.y:
			sides_to_consider["left"] = -1
			sides_to_consider["right"] = -1
			sides_to_consider["top"] = -1
			sides_to_consider["bottom"] = -1
		if tile_position.y > max_point.y:
			sides_to_consider["left"] = -1
			sides_to_consider["right"] = -1
			sides_to_consider["top"] = -1
			sides_to_consider["bottom"] = -1
		
		world_tiles[tile_position] = get_tile_with_requirements(sides_to_consider)
		
		
	return world_tiles


func are_tiles_connected(start: Vector2, end: Vector2, tilemap: Dictionary) -> bool:
	var tiles_checked := []
	var tiles_to_check := [start]
	
	while not tiles_to_check.empty():
		var current_tile = tiles_to_check.pop_back()
		
		if current_tile in tiles_checked:
			continue
		
		tiles_checked.append(current_tile)
		var adjacencies := get_adjacent_positions(current_tile)
		
		if current_tile == end:
			return true
			
		if tilemap.has(adjacencies[0]):
			if get_tile_side_value(tilemap[adjacencies[0]], "bottom") != -1:
				tiles_to_check.append(adjacencies[0])
		if tilemap.has(adjacencies[1]):
			if get_tile_side_value(tilemap[adjacencies[1]], "top") != -1:
				tiles_to_check.append(adjacencies[1])
		if tilemap.has(adjacencies[2]):
			if get_tile_side_value(tilemap[adjacencies[2]], "right") != -1:
				tiles_to_check.append(adjacencies[2])
		if tilemap.has(adjacencies[3]):
			if get_tile_side_value(tilemap[adjacencies[3]], "left") != -1:
				tiles_to_check.append(adjacencies[3])
		
		
	return false



func get_tiles_cellv(point: Vector2):
	var tile_position := get_round_point_to_tile(point)
	if not world_tile_instances.has(tile_position):
		return -1
	var tile_instance: TileMap = world_tile_instances[tile_position]
	return tile_instance.get_cellv(point - tile_position * Rooms.tile_size)


func set_tiles_cellv(point: Vector2, tile: int):
	var tile_position := get_round_point_to_tile(point)
	if not world_tile_instances.has(tile_position):
		return
	var tile_instance: TileMap = world_tile_instances[tile_position]
	tile_instance.set_cellv(point - tile_position * Rooms.tile_size, tile)

func get_round_point_to_tile(point: Vector2) -> Vector2:
	var output_x := int(point.x / Rooms.tile_size.x)
	var output_y := int(point.y / Rooms.tile_size.y)
	if point.x < 0:
		output_x = -int((-point.x - 1) / Rooms.tile_size.x) - 1
	if point.y < 0:
		output_y = -int((-point.y - 1) / Rooms.tile_size.y) - 1
	return Vector2(output_x, output_y)


func world_to_map(point: Vector2) -> Vector2:
	var output_x := int(point.x / 8)
	var output_y := int(point.y / 8)
	if point.x < 0:
		output_x = -int((-point.x - 1) / 8) - 1
	if point.y < 0:
		output_y = -int((-point.y - 1) / 8) - 1
	return Vector2(output_x, output_y)
