extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


func _process(delta: float) -> void:
	var health: Flesh = get_parent().health_object()
	if not health.body_module or not health.blood_module:
		return
	# If the player is bleeding
	if health.body_module.holes > 0 and health.blood_module.amount > 0.01:
		if health.blood_module.substance == "water" and "onfire" in health.effects:
			health.effects.erase("onfire")
		# Emit blood particles 
		for i in min(health.body_module.holes, 12):
			if randf()>0.9:
				var n :RigidBody2D = preload("res://Particles/Blood.tscn").instance()
				n.position = global_position + Vector2(0, 6)
				n.linear_velocity = Vector2(-200 + randf()*400, -80 + randf()*120)
				n.substance = health.blood_module.substance
				get_parent().get_parent().add_child(n)
