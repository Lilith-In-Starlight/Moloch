extends Camera2D


onready var player :Character = $"../Player"

var camera_offset_by_mouse := Vector2(0, 0)


func _process(delta: float) -> void:
	# Control the camera with the mouse
	var mouse_influence_on_camera := player.get_local_mouse_position()/2.5
	if Config.last_input_was_controller:
		mouse_influence_on_camera = player.last_controller_aim * 0.5
	
	if Config.camera_smoothing > 0:
		camera_offset_by_mouse += (mouse_influence_on_camera - offset) / (13 - Config.camera_smoothing)
	else:
		camera_offset_by_mouse = Vector2(0, 0)
	
	
	offset = camera_offset_by_mouse
	position = lerp(position, player.position, 0.08 * delta * 60)
