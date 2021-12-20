extends TileMap
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

class _Room:
		var scene = null
		var is_treasure :bool = false
		var is_end :bool = false
		var area :Rect2 = Rect2()
		var attachment_door

func _ready():
	if Items.level > 2:
		level_tile = 1
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
	rooms = 0
	generated_end_room = false
	treasure_rooms = 0
	while not generated_end_room or rooms <= 25:
		var children := Items.shuffle_array(get_children())
		for room in children:
			var el_children = Items.shuffle_array(room.get_children())
			for element in el_children:
					var new_room :_Room = expand_through_door(element,room) # side action: this removes the element on success
					if new_room:
						rooms += 1
						if new_room.is_treasure:
							treasure_rooms += 1
						if new_room.is_end:
							generated_end_room = true
						add_child(new_room.scene)
						areas.append(new_room.area)
						stretch_global_bounds(new_room.area)
	
	for group in ["LeftDoor","RightDoor"]:
		for element in get_tree().get_nodes_in_group(group):
			var room = element.get_parent()
			var new_room :_Room = expand_through_door_with_treasure(element, room)
			if new_room:
				rooms += 1
				treasure_rooms += 1
				add_child(new_room.scene)
				areas.append(new_room.area)
				stretch_global_bounds(new_room.area)
		
	print("Step 2: Sealing up unused doors")
	for group in ["LeftDoor","RightDoor","UpDoor","DownDoor"]:
		for door in get_tree().get_nodes_in_group(group):
			var door_in_map := world_to_map(door.position) + world_to_map(door.get_parent().position)
			var door_rect = get_door_rect(door)
			door_rect.position += door_in_map
			fill_rect(door_rect, level_tile)
	
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
	
	print("Step 4: Passing all the room data to the world TileMap")
	for room in get_children():
		if room is TileMap:
			var room_in_map := world_to_map(room.position)
			for cell in room.get_used_cells():
				set_cellv(room_in_map + cell, level_tile)
			room.queue_free()
	
	max_point /= 8.0
	max_point += Vector2(64, 32)
	min_point /= 8.0
	min_point -= Vector2(64, 32)
	fill_x = min_point.x
	print("Step 5: Filling empty space from", min_point, " to ", max_point)
	print("Area: ", (max_point.x - min_point.x) * (max_point.y - min_point.y))
	if (max_point.x - min_point.x) * (max_point.y - min_point.y) > 350000:
		get_tree().change_scene("res://Game.tscn")
	else:
		fill_empty_space_chunk()


func _process(delta):
	if filling_done:
		finalize_world()
		set_process(false)
	else:
		fill_empty_space_chunk()


func fill_empty_space_chunk():
	var chunk_end = min(fill_x+x_fill_step, max_point.x)
	
	var start := OS.get_ticks_msec()
	for x in range(fill_x, chunk_end):
		var y := min_point.y
		while y < max_point.y:
			var room := is_in_room(x, y)
			if room == Rect2(0,0,0,0):
				set_cell(x, y, level_tile)
			else:
				y += room.size.y / 8 - 1
			y += 1
	x_fill_step = readjust_chunk_size(x_fill_step, start, OS.get_ticks_msec(), 200)
	
	fill_x = chunk_end
	if chunk_end == max_point.x:
		filling_done = true

func readjust_chunk_size(chunk_size: int, start: int, end: int, desired_chunk_ms: int) -> int:
			var msec :int = end - start
			var new_size_f :float = float(desired_chunk_ms)/float(msec) * float(chunk_size)
			if new_size_f <= 1:
				new_size_f = 1
			return int(new_size_f)

func is_in_room(x: int, y: int) -> Rect2:
	for a in areas:
		if a.has_point(Vector2(x, y)*cell_size.x):
			return a
	return Rect2(0,0,0,0)

func finalize_world():
	print("Step 6: Autotiling so it's pretty")
	update_bitmask_region(min_point, max_point)
	print("Step 7: Adding enemies")
	add_enemies()
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
	for area in areas:
		for i in Items.WorldRNG.randi()%3:
			enemies.append(add_enemy_with_chance(area, preload("res://Enemies/MagicDrone.tscn"), 0.6))
			enemies.append(add_enemy_with_chance(area, preload("res://Enemies/Firemoth.tscn"), 0.6))
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
			set_cellv(rect.position+Vector2(x,y), value)

func has_property(object: Object, property_name: String) -> bool:
	for property in object.get_property_list():
		if property['name'] == property_name:
			return true
	return false
