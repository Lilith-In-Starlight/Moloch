tool
extends TileMap

export var occupies := [Vector2(0, 0)]
		

func _process(delta):
	if Engine.editor_hint:
		update()
	else:
		set_process(false)

func _draw():
	draw_rect(Rect2(0,0,66*8,33*8), ColorN("white"), false)
	draw_rect(Rect2(0,0,3*8,(29-5)*8), ColorN("white"), false)
	draw_rect(Rect2((66-3)*8,0,3*8,(29-5)*8), ColorN("white"), false)
	draw_rect(Rect2(0,0,22*8,3*8), ColorN("white"), false)
	draw_rect(Rect2(44*8,0,22*8,3*8), ColorN("white"), false)
	draw_rect(Rect2(0,30*8,22*8,3*8), ColorN("white"), false)
	draw_rect(Rect2(44*8,30*8,22*8,3*8), ColorN("white"), false)
