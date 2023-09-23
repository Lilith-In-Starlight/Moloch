extends Camera2D


onready var player :Character = $"../Player"

var noise_generator := OpenSimplexNoise.new()

var camera_offset_by_mouse := Vector2(0, 0)

var shake_amount := 0.0
var trauma := 0.0


func _process(delta: float) -> void:
	# Control the camera with the mouse
	var mouse_influence_on_camera := player.get_local_mouse_position()/2.5
	if Items.level > 0:
		mouse_influence_on_camera = get_local_mouse_position()/5.0
		zoom = Vector2(1.5, 1.5)
	
	if Config.last_input_was_controller:
		mouse_influence_on_camera = player.last_controller_aim * 0.5
	
	if Config.camera_smoothing > 0:
		camera_offset_by_mouse += (mouse_influence_on_camera - offset) / (13 - Config.camera_smoothing)
	else:
		camera_offset_by_mouse = Vector2(0, 0)
	
	
	# Camera shake
	shake_amount = pow(trauma, 2)
	var offset_by_camera_shake := Vector2()
	offset_by_camera_shake.x = noise_generator.get_noise_2d(Time.get_ticks_msec(), 218668)
	offset_by_camera_shake.y = noise_generator.get_noise_2d(Time.get_ticks_msec(), 561964)
	trauma = move_toward(trauma, 0.0, 0.5 * delta * 60)
	
	var shake_percentage = Config.screen_shake / 12.0
	offset = camera_offset_by_mouse + offset_by_camera_shake * shake_amount * shake_percentage
	var to := player.position
	if Items.is_level_boss():
		to.x = 263.5
		to.y -= 100
		if player.position.y < -268:
			to = Vector2(263.5, -268 - 134)
	position = lerp(position, to, 0.08 * delta * 60)


func shake_camera(amount: float):
	if trauma < amount:
		trauma = amount
	
	if trauma > 10.0:
		trauma = 10.0
