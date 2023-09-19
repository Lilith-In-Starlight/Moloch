extends Node

class_name ParicleMovement

signal request_death()
signal request_movement(delta)
signal collision_happened(collider, collision_point, collision_normal)

var velocity := Vector2(0,0)
var raycast : RayCast2D

var bounces := 0
var max_bounces := 1
var gravity := 200.0


func _ready() -> void:
	raycast = RayCast2D.new()
	raycast.collision_mask = 91
	get_parent().add_child(raycast)


func set_up_to(node: Node2D):
	connect("request_death", node, "_on_request_death")
	connect("request_movement", node, "_on_request_movement")
	


func _physics_process(delta: float) -> void:
	raycast.cast_to = velocity * delta
	raycast.force_raycast_update()
	
	if bounces >= max_bounces:
		emit_signal("request_death")
	
	if raycast.is_colliding():
		bounces += 1
		emit_signal("collision_happened", raycast.get_collider(), raycast.get_collision_point(), raycast.get_collision_normal())
		emit_signal("request_movement", raycast.get_collision_point() - raycast.global_position - velocity.normalized())
	else:
		emit_signal("request_movement", velocity * delta)
