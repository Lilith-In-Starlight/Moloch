extends StatusEffect

class_name OnFire

func _ready() -> void:
	effect_name = "onfire"
	duration = 6 + randf() * 6.0


func _process(delta: float) -> void:
	if get_parent().temperature_module and get_parent().body_module:
		if get_parent().body_module.is_flammable:
			get_parent().temp_change(10 * delta)
		else:
			remove_effect()
			
	._process(delta)
