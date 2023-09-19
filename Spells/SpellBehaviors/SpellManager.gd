extends Node2D

class_name SpellManager

var movement_manager :Node = null


func _on_request_movement(delta) -> void:
	position += delta

func _on_request_death() -> void:
	queue_free()
