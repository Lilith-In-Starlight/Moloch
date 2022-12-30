extends Node2D


func _ready() -> void:
	for i in get_children():
		i.cast_to = Vector2(1, 0).rotated(-randf() * PI) * 30*8
		i.force_raycast_update()
		if i.is_colliding():
			var n: RigidBody2D = preload("res://Particles/EarthquakeDebris.tscn").instance()
			n.position = i.get_collision_point() + i.cast_to.normalized() * 8
			n.apply_central_impulse((n.position - position) * 5)
			get_parent().add_child(n)
