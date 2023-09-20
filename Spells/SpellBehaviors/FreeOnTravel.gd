extends Node

signal request_death

class_name FreeOnTravel

var max_distance := 100.0
var current_distance := 100

var free_requested := false

func _on_request_movement(delta: Vector2):
	if free_requested: return
	current_distance += delta.length()
	if current_distance >= max_distance:
		free_requested = true
		emit_signal("request_death")

