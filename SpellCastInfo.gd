extends Resource

class_name SpellCastInfo

var Caster :Node2D
var goal :Vector2
var goal_offset := Vector2(0, 0)


func set_position(CastEntity:Node2D):
	if is_instance_valid(Caster):
		if Caster.has_method("cast_from"):
			CastEntity.position = Caster.cast_from()
			return
		CastEntity.position = Caster.position


func set_goal():
	if is_instance_valid(Caster):
		if Caster.has_method("looking_at"):
			goal = Caster.looking_at() + goal_offset


func get_angle(CastEntity:Node2D) -> float:
	return goal.angle_to_point(CastEntity.position)
