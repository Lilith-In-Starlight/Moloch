extends Node

class_name DestroyWorld

signal destroy_tile(amount)

onready var WorldMap: Node2D = get_tree().get_nodes_in_group("World")[0]

var radius: int = 2

func _on_collision_happened(collider: Node, collision_point: Vector2, _a: Vector2):
	destroy_world(collider, collision_point)


func _on_body_entered(body: Node, spell: Node) -> void:
	destroy_world(body, spell.global_position)


func destroy_world(collider: Node, collision_point: Vector2):
	var pos :Vector2 = collision_point
	if collider.is_in_group("WorldPiece"):
#		CastInfo.push_caster(-(pos-position).normalized()*10)
		pos.x = int(pos.x/8)
		pos.y = int(pos.y/8)
		var tiles_broken := 0
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				var v := Vector2(x, y)
				if v.length() < radius:
					tiles_broken += 1
					WorldMap.set_tiles_cellv(v+pos,-1)
		emit_signal("destroy_tile", tiles_broken)

