extends Node


class_name RayBehavior

var angle := 0.0

func get_angle(start: Vector2, end: Vector2, cast_info: SpellCastInfo):
	var output := start.angle_to_point(end)
	if cast_info.modifiers.has("orthogonal"):
		var deg = rad2deg(output)
		deg = int(deg / 45) * 45
		output = deg2rad(deg)
	angle = output
	return output


func get_cast_to(length: float, cast_info: SpellCastInfo) -> Vector2:
	if cast_info.modifiers.has("limited"):
		cast_info.vector_from_angle(angle, 2)
	return cast_info.vector_from_angle(angle, length)
	
