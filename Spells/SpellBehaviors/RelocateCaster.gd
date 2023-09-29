extends Node

class_name RelocateCasterModule

var coll := false

func _on_collision_happened(_collider, _point, normal) -> void:
	get_parent().CastInfo.teleport_caster(get_parent().position + normal * 8.0)
	coll = true

func _on_request_movement(_delta) -> void:
	if coll: return
	get_parent().CastInfo.teleport_caster(get_parent().position)
