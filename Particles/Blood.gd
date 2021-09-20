extends RigidBody2D

var timer := 0.0

func _physics_process(delta):
	timer += delta
	if modulate.a <= 0.0:
		queue_free()
	if timer > 0.5:
		modulate.a -= 0.05
	$Polygon2D.rotation = linear_velocity.angle()
