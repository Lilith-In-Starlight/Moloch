extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


func _process(delta: float) -> void:
	var health = get_parent().health_object()
	# If the player is bleeding
	if health.poked_holes > 0 and health.blood > 0.01:
		if health.blood_substance == "water" and "onfire" in health.effects:
			health.effects.erase("onfire")
		# Emit blood particles 
		for i in min(health.poked_holes, 12):
			if randf()>0.9:
				var n :RigidBody2D = preload("res://Particles/Blood.tscn").instance()
				n.position = global_position + Vector2(0, 6)
				n.linear_velocity = Vector2(-200 + randf()*400, -80 + randf()*120)
				n.substance = health.blood_substance
				get_parent().get_parent().add_child(n)
