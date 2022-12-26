extends RayCast2D


class_name RayBehavior

signal hit_something
signal hit_nothing

var angle := 0.0

var length := 2000


func _ready() -> void:
	set_collision_mask_bit(0, true)
	set_collision_mask_bit(1, true)
	set_collision_mask_bit(3, true)
	set_collision_mask_bit(4, true)
	set_collision_mask_bit(6, true)


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


func get_cast_to_from_cast_info(cast_info: SpellCastInfo) -> Vector2:
	if cast_info.modifiers.has("limited"):
		cast_info.vector_from_angle(angle, 2)
	return cast_info.vector_from_angle(angle, length)
	

func cast(cast_info: SpellCastInfo):
	cast_to = get_cast_to_from_cast_info(cast_info)
	force_raycast_update()
	if is_colliding():
		emit_signal("hit_something")
	else:
		emit_signal("hit_nothing")
