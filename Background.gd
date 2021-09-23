extends CanvasLayer


onready var Tiles := $Following
var Cam :Camera2D

func _ready():
	Cam = get_tree().get_nodes_in_group("Camera")[0]

func _process(delta):
	var cam_pos := Cam.get_camera_position() + Cam.offset - Vector2(400, 225)/2.0
	var x := -1
	var y := -1
	var i := 0
	for Tile in Tiles.get_children():
		Tile.rect_position.x = stepify(cam_pos.x, 400)+400*x
		Tile.rect_position.y = stepify(cam_pos.y, 225)+225*y - i
		x += 1
		if x > 1:
			i += 1
			x = -1
			y += 1
