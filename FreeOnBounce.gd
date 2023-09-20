extends Node

signal request_death

class_name FreeOnBounce

var max_bounces := 1
var bounces := 0

var free_requested := false  

func _on_collision_happened(collider: Node, collision_point: Vector2, collision_normal: Vector2):
	if free_requested: return
	bounces += 1
	if bounces >= max_bounces:
		free_requested = true
		emit_signal("request_death")

