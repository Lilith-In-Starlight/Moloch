extends Polygon2D

#var time := 0.0
#var noise := OpenSimplexNoise.new()
#var noise2 := OpenSimplexNoise.new()
#var seconds := 2.0
#
#
#func _ready() -> void:
#	modulate.a = 0
#	set_process(false)
#	noise.seed = randi()
#	noise2.seed = randi()
#
#
#func _process(delta: float) -> void:
#	time += delta * 60
#	position.x += noise.get_noise_2d(position.x, time) * delta * 60 * time / 30.0
#	position.y += noise2.get_noise_2d(position.y, time) * delta * 60 * time / 30.0
#	if time > 60 * seconds:
#		queue_free()
#	modulate.a = lerp(modulate.a, 1.5 - time / (60.0 * seconds), 0.08)
#

func _on_Timer_timeout() -> void:
	queue_free()
