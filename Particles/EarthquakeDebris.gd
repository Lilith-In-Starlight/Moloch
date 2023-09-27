extends RigidBody2D

var Map :Node2D
var position_in_map: Vector2

const adjacencies = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

func _ready() -> void:
	Map = get_tree().get_nodes_in_group("World")[0]
	position_in_map = Map.world_to_map(position)
	var to_check := [Vector2.ZERO]
	var checked := []
	var chance := 2.0
	if Map.get_tiles_cellv(position_in_map) == -1:
		return
	for i in to_check:
		checked.append(i)
		if Map.get_tiles_cellv(position_in_map + i) == -1: continue
		if Map.get_tiles_cellv(position_in_map) == 2: continue
		if randf() > chance:
			break
		$TileMap.set_cellv(i, Map.get_tiles_cellv(position_in_map + i))
		Map.set_tiles_cellv(position_in_map + i, -1)
		var adj := adjacencies.duplicate()
		adj.shuffle()
		for j in adjacencies:
			if not j + i in checked:
				to_check.append(j + i)
				chance *= 0.98

