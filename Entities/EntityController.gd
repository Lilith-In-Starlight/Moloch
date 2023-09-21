extends Node

class_name EntityController

var pressed_inputs := InputData.new()
var just_pressed_inputs := InputData.new()


func get_movement_axis() -> Vector2:
	return Vector2(0, 0)
