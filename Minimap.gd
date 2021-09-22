extends Control

var been_to := []

func _process(delta):
	update()

func _draw():
	for i in get_tree().get_nodes_in_group("World")[0].areas:
		var r :Rect2= i
		r.position = r.position/16.0/4.0-get_tree().get_nodes_in_group("Player")[0].position/16.0/4.0
		r.size = r.size/16.0/4.0
		if r.has_point(Vector2(0, 0)) or been_to.has(i):
			draw_rect(r, ColorN("white"), true)
			if not been_to.has(i):
				been_to.append(i)
		else:
			draw_rect(r, ColorN("white"), false)
	if Items.player_items.has("monocle"):
		for i in get_tree().get_nodes_in_group("Chest"):
			draw_circle(i.position/16.0/4.0-get_tree().get_nodes_in_group("Player")[0].position/16.0/4.0, 1.0, ColorN("green"))
	draw_circle(Vector2(0, 0), 1.0, ColorN("black"))
