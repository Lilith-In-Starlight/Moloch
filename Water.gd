extends Node2D

var water := {}
func _process(delta):
	if Input.is_action_pressed("Interact1"):
		var p := world_to_map(get_global_mouse_position())
		water[p] = 8.0
	
	var aa := water.keys()
	aa.shuffle()
	var actions := []
	for pos in aa:
		if water[pos]:
			var dcell = pos + Vector2.DOWN
			var rcell = pos + Vector2.RIGHT
			var lcell = pos + Vector2.LEFT
			var ucell = pos + Vector2.DOWN
			if not dcell in water:
				water[dcell] = 0
			if not lcell in water:
				water[lcell] = 0
			if not rcell in water:
				water[rcell] = 0
			if not ucell in water:
				water[ucell] = 0
			
			var flow := 0.0
			if get_cellv(dcell) == -1:
				pass
	for i in actions:
		water[i[0]] += i[1]
		
	update()

func _draw():
	for i in water:
		if water[i]> 0.1:
			draw_rect(Rect2(i*8 + Vector2(0, 8-clamp(water[i], 0, 8)), Vector2(8, clamp(water[i], 0, 8))), ColorN("blue", 0.5))
