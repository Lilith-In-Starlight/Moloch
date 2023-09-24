extends StatusEffect

class_name Confused

func _ready() -> void:
	effect_name = "confused"
	duration = randf() * 6.0


func _process(delta: float) -> void:
	if get_parent().temperature_module:
		pass
	
	get_parent().temp_change(2 * delta)
	._process(delta)
