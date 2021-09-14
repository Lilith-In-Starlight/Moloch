extends Node2D

var block := 0
var doors := []

func _process(delta):
	if Input.is_key_pressed(KEY_W):
		$Editor.position.y += 4
	if Input.is_key_pressed(KEY_S):
		$Editor.position.y -= 4
	if Input.is_key_pressed(KEY_A):
		$Editor.position.x += 4
	if Input.is_key_pressed(KEY_D):
		$Editor.position.x -= 4
	if Input.is_key_pressed(KEY_R):
		$Editor.position = Vector2.ZERO
	
	var pos = $Editor.world_to_map(get_global_mouse_position() - $Editor.position)
	if Input.is_action_pressed("Interact1"):
		$Editor.set_cellv(pos, block)
	elif Input.is_action_pressed("Interact2"):
		$Editor.set_cellv(pos, -1)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			block += 1
			if block > 0:
				block = 0
		elif event.button_index == BUTTON_WHEEL_DOWN:
			block -= 1
			if block < -1:
				block = -1
