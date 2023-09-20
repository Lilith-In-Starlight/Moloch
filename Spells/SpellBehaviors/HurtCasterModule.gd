extends Node

class_name HurtCasterModule


var caster :Node = null


func change_temp(deg: float) -> void:
	if caster.has_method("health_object"):
		caster.health_object().temp_change(deg, caster, true)


func push(force: Vector2) -> void:
	if caster.get("speed"):
		caster.speed += force
	elif caster.get("linear_velocity"):
		caster.linear_velocity += force
