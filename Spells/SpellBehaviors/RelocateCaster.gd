extends Node

class_name RelocateCasterModule

func _on_collision_happened(_collider, _point, _normal) -> void:
	get_parent().CastInfo.teleport_caster(get_parent().position)

func _on_request_movement(_delta) -> void:
	get_parent().CastInfo.teleport_caster(get_parent().position)
