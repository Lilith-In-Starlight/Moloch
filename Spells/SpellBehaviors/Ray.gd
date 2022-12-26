extends Node


class_name RayBehavior

signal hit_something
signal never_hit_something

var angle := 0.0

var length := 2000


func ray_setup(entity: Node2D, ray_length: float):
	entity.CastInfo.set_position(entity)
	entity.CastInfo.set_goal()
	length = ray_length
	get_angle(entity.CastInfo.goal, entity.position, entity.CastInfo)


func get_angle(start: Vector2, end: Vector2, cast_info: SpellCastInfo):
	var output := start.angle_to_point(end)
	if cast_info.modifiers.has("orthogonal"):
		var deg = rad2deg(output)
		deg = int(deg / 45) * 45
		output = deg2rad(deg)
	angle = output
	return output


func get_cast_to(cast_info: SpellCastInfo) -> Vector2:
	if cast_info.modifiers.has("limited"):
		cast_info.vector_from_angle(angle, 2)
	return cast_info.vector_from_angle(angle, length)
	
