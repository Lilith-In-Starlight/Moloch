extends Resource

class_name SpellCastInfo

var Caster :Node2D
var wand :Wand = null
var goal :Vector2
var goal_offset := Vector2(0, 0)

var spell_offset := Vector2(0, 0)

var modifiers := []


func set_position(CastEntity:Node2D):
	if wand != null:
		if wand.spell_offset != Vector2(0, 0):
			spell_offset = wand.spell_offset
	if is_instance_valid(Caster):
		if Caster.has_method("cast_from"):
			CastEntity.position = Caster.cast_from() + spell_offset
			return
		CastEntity.position = Caster.position + spell_offset


func set_goal():
	if is_instance_valid(Caster):
		if Caster.has_method("looking_at"):
			goal = Caster.looking_at() + goal_offset


func get_angle(CastEntity:Node2D) -> float:
	return (goal + goal_offset).angle_to_point(CastEntity.position)


func heat_caster(temp:float) -> void:
	if is_instance_valid(Caster) and Caster.has_method("health_object"):
		if wand != null:
			Caster.health_object().temp_change(temp*wand.heat_resistance, null, true)
		else:
			Caster.health_object().temp_change(temp, null, true)


func drain_caster_soul(soul:float) -> void:
	if is_instance_valid(Caster) and Caster.has_method("health_object"):
		if wand != null:
			Caster.health_object().shatter_soul(soul*wand.soul_resistance, null, true)
		else:
			Caster.health_object().shatter_soul(soul, null, true)


func push_caster(push:Vector2) -> void:
	if is_instance_valid(Caster):
		var push_to_do := push
		if wand != null:
			push_to_do = push*wand.push_resistance
		if Caster.get("speed"):
			Caster.speed += push_to_do
		elif Caster.get("linear_velocity"):
			Caster.linear_velocity += push_to_do


func teleport_caster(relpos:Vector2) -> void:
	if is_instance_valid(Caster):
		Caster.position += relpos + (Caster.cast_from() - Caster.position)
		if Caster.get("speed"):
			Caster.speed = Vector2(0, 0)
		elif Caster.get("linear_velocity"):
			Caster.linear_velocity = Vector2(0, 0)


func vector_from_angle(angle:float, length:float) -> Vector2:
	if "limited" in modifiers:
		return Vector2(cos(angle), sin(angle)) * 2.0
	return Vector2(cos(angle), sin(angle)) * length
