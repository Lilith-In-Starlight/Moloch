tool
extends Position2D

export var maximum := 5
export(RectangleShape2D) var shape:RectangleShape2D

func _ready():
	if not Engine.editor_hint:
		set_process(false)
		for i in Items.WorldRNG.randi()%maximum:
			var n := preload("res://RoomDecorations/Poster.tscn").instance()
			n.position = global_position - shape.extents/2.0*8.0
			n.position += Vector2(Items.WorldRNG.randf(), Items.WorldRNG.randf())*shape.extents*8.0
			n.z_index = -1
			get_parent().get_parent().call_deferred("add_child", n)

func _process(_delta):
	if Engine.editor_hint and shape != null:
		update()

func _draw():
	if Engine.editor_hint:
		draw_rect(Rect2(-shape.extents/2.0*8.0, shape.extents*8.0), ColorN("dark_green", 0.5))
