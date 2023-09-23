extends Node


class_name HurtOnCollide

var soul_damage := 0.0
var poke_holes := 0
var heat_damage := 0.0
var caster :Node = null
var effects :Array = []


func _on_collision_happened(collider: Node, collision_point: Vector2, collision_normal: Vector2):
	if not collider.has_method("health_object"):
		return
	
	if collider == caster and "self_immunity" in get_parent().CastInfo.modifiers:
		return
	
	if poke_holes != 0:
		collider.health_object().poke_hole(poke_holes, caster)
	collider.health_object().shatter_soul(soul_damage, caster)
	collider.health_object().temp_change(heat_damage, caster)
	for i in effects:
		collider.health_object().add_effect(i)

