extends Particles2D


func _on_request_movement(delta: Vector2) -> void:
	position += delta
	var mat : ParticlesMaterial = material
	rotation = delta.angle()
	
	

func _on_request_death() -> void:
	yield(VisualServer, "frame_post_draw")
	queue_free()
