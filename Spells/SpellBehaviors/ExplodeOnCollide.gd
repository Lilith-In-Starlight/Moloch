extends Node


class_name ExplodeOnCollide


func _on_collision_happened(collider: Node, collision_point: Vector2, _a: Vector2):
	var Map = get_tree().get_nodes_in_group("World")[0]
	Map.summon_explosion(collision_point, 8)
