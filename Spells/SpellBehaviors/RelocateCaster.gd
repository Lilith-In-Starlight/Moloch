extends Node

class_name RelocateCasterModule

func _on_collision_happened(_collider, _point, _normal) -> void:
	get_parent().CastInfo.teleport_caster(get_parent().position)
