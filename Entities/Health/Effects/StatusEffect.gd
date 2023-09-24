extends Node

class_name StatusEffect


signal effect_ended(name)

var duration := 0.0
var effect_name := ""

func _process(delta: float) -> void:
	duration -= delta
	if duration <= 0.0:
		remove_effect()


func remove_effect():
	emit_signal("effect_ended", effect_name)
	get_parent().remove_effect(effect_name)
	queue_free()
