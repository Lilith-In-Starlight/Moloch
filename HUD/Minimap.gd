extends Control

var been_to := []
var drawn_edge_to := []
var edges := []

func _ready() -> void:
	set_process(false)

func _process(_delta):
	update()

func _draw():
	var door_points := []
	for i in get_tree().get_nodes_in_group("World")[0].world_tile_instances:
		var r :Rect2 = Rect2(i * Rooms.tile_size * 8 + Vector2.ONE * 16, Rooms.tile_size * 8 - Vector2.ONE * 32)
		r.position = r.position/16.0/4.0-get_tree().get_nodes_in_group("Player")[0].position/16.0/4.0
		r.size = r.size/16.0/4.0
		if r.has_point(Vector2(0, 0)) or been_to.has(i):
			draw_rect(r, ColorN("white"), true)
			if not i in drawn_edge_to:
				drawn_edge_to.append(i)
				if get_tree().get_nodes_in_group("World")[0].world_tile_instances[i].top != -1 and not i + Vector2.UP in edges:
					edges.append(i + Vector2.UP)
				if get_tree().get_nodes_in_group("World")[0].world_tile_instances[i].left != -1 and not i + Vector2.LEFT in edges:
					edges.append(i + Vector2.LEFT)
				if get_tree().get_nodes_in_group("World")[0].world_tile_instances[i].bottom != -1 and not i + Vector2.DOWN in edges:
					edges.append(i + Vector2.DOWN)
				if get_tree().get_nodes_in_group("World")[0].world_tile_instances[i].right != -1 and not i + Vector2.RIGHT in edges:
					edges.append(i + Vector2.RIGHT)
			if not been_to.has(i):
				been_to.append(i)
			else:
				edges.erase(i)
	for i in edges:
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
