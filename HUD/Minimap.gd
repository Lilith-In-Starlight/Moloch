extends Control

var tiles_player_has_been_to := []
var tiles_whose_adjacencies_been_drawn := []
var tile_adjacencies := []


func _ready() -> void:
	add_to_group("Persistent")
	set_process(false)
	


func _process(_delta):
	update()


func _draw():
	var door_points := []
	var world_tile_instances :Dictionary = get_tree().get_nodes_in_group("World")[0].world_tile_instances
	
	for i in world_tile_instances:
		var tile_rect :Rect2 = Rect2(i * Rooms.tile_size * 8 + Vector2.ONE * 16, Rooms.tile_size * 8 - Vector2.ONE * 32)
		var tile_instance = world_tile_instances[i]
		
		if tile_instance.right != -1:
			tile_rect.size.x += 16.0
		if tile_instance.left != -1:
			tile_rect.position.x -= 16.0
			tile_rect.size.x += 16.0
		if tile_instance.bottom != -1:
			tile_rect.size.y += 16.0
		if tile_instance.top != -1:
			tile_rect.position.y -= 16.0
			tile_rect.size.y += 16.0
		
		
		tile_rect.position = tile_rect.position/16.0/4.0-get_tree().get_nodes_in_group("Player")[0].position/16.0/4.0
		tile_rect.size = tile_rect.size/16.0/4.0
		
		if tile_rect.has_point(Vector2(0, 0)) or tiles_player_has_been_to.has(i) and (tile_instance.right + tile_instance.left + tile_instance.top + tile_instance.bottom) > -4:
			draw_rect(tile_rect, ColorN("white"), true)
			
			if not i in tiles_whose_adjacencies_been_drawn:
				tiles_whose_adjacencies_been_drawn.append(i)
				if world_tile_instances[i].top != -1 and not i + Vector2.UP in tile_adjacencies:
					if get_tile_side(i + Vector2.UP, "bottom", world_tile_instances) != -1:
						tile_adjacencies.append(i + Vector2.UP)
						
				if world_tile_instances[i].left != -1 and not i + Vector2.LEFT in tile_adjacencies:
					if get_tile_side(i + Vector2.LEFT, "right", world_tile_instances) != -1:
						tile_adjacencies.append(i + Vector2.LEFT)
						
				if world_tile_instances[i].bottom != -1 and not i + Vector2.DOWN in tile_adjacencies:
					if get_tile_side(i + Vector2.DOWN, "top", world_tile_instances) != -1:
						tile_adjacencies.append(i + Vector2.DOWN)
						
				if world_tile_instances[i].right != -1 and not i + Vector2.RIGHT in tile_adjacencies:
					if get_tile_side(i + Vector2.RIGHT, "left", world_tile_instances) != -1:
						tile_adjacencies.append(i + Vector2.RIGHT)
			
			if not tiles_player_has_been_to.has(i):
				tiles_player_has_been_to.append(i)
			else:
				tile_adjacencies.erase(i)
	
	
	for i in tile_adjacencies:
		var v:Vector2 = i
		var r:Rect2 = Rect2(i * Rooms.tile_size * 8 + Vector2.ONE * 16, Rooms.tile_size * 8 - Vector2.ONE * 32)
		r.position = r.position/16.0/4.0-get_tree().get_nodes_in_group("Player")[0].position/16.0/4.0
		r.size = r.size/16.0/4.0
		draw_rect(r, ColorN("white"), false)
	
	for pos in door_points:
		draw_circle(pos, 1, ColorN("cadetblue"))
	
	
	if Items.count_player_items("monocle") > 0:
		for i in get_tree().get_nodes_in_group("Chest"):
			draw_circle(i.position/16.0/4.0-get_tree().get_nodes_in_group("Player")[0].position/16.0/4.0, 1.0, ColorN("green"))
	draw_circle(Vector2(0, 0), 1.0, ColorN("black"))


func _on_generated_world() -> void:
	set_process(true)
	var world = get_tree().get_nodes_in_group("World")[0]
	if not world.loaded_entities_from_file:
		return
	tiles_player_has_been_to = Config.playthrough_file.get_value("Player", "tiles_player_has_been_to", [])
	tiles_whose_adjacencies_been_drawn = Config.playthrough_file.get_value("Player", "tiles_whose_adjacencies_been_drawn", [])
	tile_adjacencies = Config.playthrough_file.get_value("Player", "tile_adjacencies", [])


func get_tile_side(tile:Vector2, side: String, all_tiles: Dictionary):
	if not all_tiles.has(tile):
		return -1
	else:
		if side == "top":
			return all_tiles[tile].top
		if side == "bottom":
			return all_tiles[tile].bottom
		if side == "right":
			return all_tiles[tile].right
		if side == "left":
			return all_tiles[tile].left


func _on_exit() -> void:
	Config.playthrough_file.set_value("Player", "tiles_player_has_been_to", tiles_player_has_been_to)
	Config.playthrough_file.set_value("Player", "tiles_whose_adjacencies_been_drawn", tiles_whose_adjacencies_been_drawn)
	Config.playthrough_file.set_value("Player", "tile_adjacencies", tile_adjacencies)
