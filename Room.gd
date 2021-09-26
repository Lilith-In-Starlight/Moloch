tool
extends TileMap

export var occupies := [Vector2(0, 0)]
var decos := []


func _ready():
	if not Engine.editor_hint:
		for i in get_children():
			if i.is_in_group("Vases"):
				var no = i.get_node_or_null("End")
				if no != null:
					var pos = i.position
					while pos.x < no.position.x + i.position.x:
						if Items.WorldRNG.randf() < 0.15:
							var n := preload("res://Elements/Vase.tscn").instance()
							n.position = pos - Vector2(0, 3)
							add_child(n)
						pos.x += 17 + Items.WorldRNG.randf()*8


func _process(delta):
	if Engine.editor_hint:
		update()
	else:
		set_process(false)


func _draw():
	for i in get_tree().get_nodes_in_group("Vases"):
		var n = i.get_node_or_null("End")
		if n != null:
			draw_rect(Rect2(i.position, Vector2(i.get_node("End").position.x, -8)), ColorN("blue",0.2))
	draw_rect(Rect2(0,0,66*8,33*8), ColorN("white"), false)
	draw_rect(Rect2(0,0,3*8,(29-5)*8), ColorN("white"), false)
	draw_rect(Rect2((66-3)*8,0,3*8,(29-5)*8), ColorN("white"), false)
	draw_rect(Rect2(0,0,22*8,3*8), ColorN("white"), false)
	draw_rect(Rect2(44*8,0,22*8,3*8), ColorN("white"), false)
	draw_rect(Rect2(0,30*8,22*8,3*8), ColorN("white"), false)
	draw_rect(Rect2(44*8,30*8,22*8,3*8), ColorN("white"), false)
