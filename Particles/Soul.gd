extends Sprite


func _process(delta: float) -> void:
	position.y += (-3.0+randf()*6.0)*delta*60.0
	position.x += (-3.0+randf()*+6.0)*delta*60.0


func _on_Timer_timeout() -> void:
	queue_free()
