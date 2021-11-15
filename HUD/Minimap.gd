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
	for i in get_tree().get_nodes_in_group("World")[0].areas:
		var r :Rect2= i
		r.position = r.position/16.0/4.0-get_tree().get_nodes_in_group("Player")[0].position/16.0/4.0
		r.size = r.size/16.0/4.0
		if r.has_point(Vector2(0, 0)) or been_to.has(i):
			draw_rect(r, ColorN("white"), true)
			if not i in drawn_edge_to:
				drawn_edge_to.append(i)
				for j in get_tree().get_nodes_in_group("World")[0].areas:
					if j in edges or j in been_to:
						continue
					var r2 :Rect2= j
					r2.position = r2.position/16.0/4.0-get_tree().get_nodes_in_group("Player")[0].position/16.0/4.0
					r2.size = r2.size/16.0/4.0
					var r3 := r
					r3.position -= Vector2.ONE*1
					r3.size += Vector2.ONE*2
					if r2.intersects(r3, true):
						edges.append(j)
			if not been_to.has(i):
				been_to.append(i)
			else:
				edges.erase(i)
	for i in edges:
		var r:Rect2 = i
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
