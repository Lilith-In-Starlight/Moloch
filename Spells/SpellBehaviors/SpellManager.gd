extends Node2D

class_name SpellManager

signal death_requested

var CastInfo :SpellCastInfo = SpellCastInfo.new()

var movement_manager :Node = null
var side_effects :Node = null
var areas_of_effect :Array = []

func _on_request_movement(delta) -> void:
	position += delta

func _on_request_death() -> void:
	emit_signal("death_requested")
	queue_free()
