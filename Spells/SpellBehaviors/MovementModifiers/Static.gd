extends Node

signal request_movement(delta)

class_name StaticMovementModifier


func _on_request_movement(delta: Vector2) -> void:
	emit_signal("request_movement", Vector2(0, 0))
