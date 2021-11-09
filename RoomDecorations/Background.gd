extends CanvasLayer


onready var Tiles := $Following
var Cam :Camera2D
var Map :TileMap

const TILE_SIZE := Vector2(400, 224)

func _ready():
	Cam = get_tree().get_nodes_in_group("Camera")[0]
	Map = get_tree().get_nodes_in_group("World")[0]

func _process(_delta):
	var cam_pos := Cam.get_camera_position() + Cam.offset - Vector2(400, 225)/2.0
	var x := -1
	var y := -1
	var i := 0
	for Tile in Tiles.get_children():
		Tile.rect_position.x = stepify(cam_pos.x, TILE_SIZE.x)+TILE_SIZE.x*x
		Tile.rect_position.y = stepify(cam_pos.y, TILE_SIZE.y)+TILE_SIZE.y*y
		x += 1
		if x > 1:
			i += 1
			x = -1
			y += 1


func _on_generated_world() -> void:
	if Map.level_tile == 1:
		for Tile in Tiles.get_children():
			Tile.texture = preload("res://Sprites/Blocks/BrownBackgroundTile.png")
