extends RigidBody2D

var timer := 0.0
var substance := "blood"

func _physics_process(delta):
	timer += delta
	if modulate.a <= 0.0:
		queue_free()
	if timer > 0.5:
		modulate.a -= 0.05
	$Polygon2D.rotation = linear_velocity.angle()
	
	if substance == "lava":
		for i in $Area2D.get_overlapping_bodies():
			if i.has_method("health_object"):
				i.health_object().temperature += 10.0
