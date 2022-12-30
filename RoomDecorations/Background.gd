extends CanvasLayer


onready var Tiles := $Following
var Cam :Camera2D
var Map :Node2D

var TileRNG := RandomNumberGenerator.new()

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
		TileRNG.seed = Tile.rect_position.x * Tile.rect_position.y
		if Map.level_tile == 0:
			match TileRNG.randi()%2:
				0:
					Tile.texture = preload("res://Sprites/Blocks/RedBackgroundTiles/Tile2.png")
				1:
					Tile.texture = preload("res://Sprites/Blocks/RedBackgroundTiles/Tile3.png")
				2:
					Tile.texture = preload("res://Sprites/Blocks/RedBackgrounTile.png")
		else:
			match TileRNG.randi()%5:
				0:
					Tile.texture = preload("res://Sprites/Blocks/BrownBackgroundTiles/Tile2.png")
				1:
					Tile.texture = preload("res://Sprites/Blocks/BrownBackgroundTiles/Tile3.png")
				2:
					Tile.texture = preload("res://Sprites/Blocks/BrownBackgroundTiles/Tile4.png")
				3:
					Tile.texture = preload("res://Sprites/Blocks/BrownBackgroundTiles/Tile5.png")
				4:
					Tile.texture = preload("res://Sprites/Blocks/BrownBackgroundTile.png")


func _on_generated_world() -> void:
	if Map.level_tile == 1:
		for Tile in Tiles.get_children():
			Tile.texture = preload("res://Sprites/Blocks/BrownBackgroundTile.png")
