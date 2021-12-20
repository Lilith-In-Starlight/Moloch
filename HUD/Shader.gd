extends TextureRect

var offset_red := Vector2(0, 0)
var offset_blue := Vector2(0, 0)
var offset_green := Vector2(0, 0)

var noise := OpenSimplexNoise.new()
var time := 0.0

func _process(delta: float) -> void:
	time += delta
	if Items.player_health.soul <= Items.player_health.needed_soul:
		offset_red = Vector2(0, 0)
		offset_blue = Vector2(0, 0)
		offset_green = Vector2(0, 0)
	else:
		var aa := (Items.player_health.soul / Items.player_health.needed_soul)
		offset_red = aa * Vector2(noise.get_noise_2d(Engine.get_frames_drawn() * 5.0, 500), noise.get_noise_2d(Engine.get_frames_drawn() * 3.0, 0))
		offset_blue = aa * Vector2(noise.get_noise_2d(Engine.get_frames_drawn() * 5.0, 1000), noise.get_noise_2d(Engine.get_frames_drawn() * 3.0, 1500))
		offset_green = aa * Vector2(noise.get_noise_2d(Engine.get_frames_drawn() * 5.0, 2000), noise.get_noise_2d(Engine.get_frames_drawn() * 3.0, 2500))
	
	var mat:ShaderMaterial = get_material()
	var soul_offset_blue = mat.get_shader_param("soul_offset_blue")
	var soul_offset_red = mat.get_shader_param("soul_offset_red")
	var soul_offset_green = mat.get_shader_param("soul_offset_red")
	mat.set_shader_param("soul_offset_blue", lerp(soul_offset_blue, offset_blue, 0.9))
	mat.set_shader_param("soul_offset_green", lerp(soul_offset_green, offset_green, 0.9))
	mat.set_shader_param("soul_offset_red", lerp(soul_offset_red, offset_red, 0.9))
