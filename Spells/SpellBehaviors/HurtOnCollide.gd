extends Node


class_name HurtOnCollide

var soul_damage := 0.0
var poke_holes := 0
var caster :Node = null


func _on_collision_happened(collider: Node, collision_point: Vector2, collision_normal: Vector2):
	if collider.has_method("health_object"):
		collider.health_object().poke_hole(poke_holes, caster)
		collider.health_object().shatter_soul(soul_damage, caster)

