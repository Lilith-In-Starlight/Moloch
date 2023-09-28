extends Resource

class_name SpellCastInfo

var Caster :Node
var spell :Spell
var wand :Wand = null
var goal :Vector2
var angle_offset :float
var goal_offset := Vector2(0, 0)

var spell_offset := Vector2(0, 0)

var modifiers := []


var last_known_caster_position := Vector2(0, 0)
var last_known_cast_from := Vector2(0, 0)
var last_known_looking_at := Vector2(0, 0)


func set_position(CastEntity:Node2D):
	if get_position() != null and is_instance_valid(CastEntity):
		CastEntity.position = get_position()


func get_position():
	if is_instance_valid(wand):
		if wand.spell_offset != Vector2(0, 0):
			spell_offset = wand.spell_offset
	
	if is_instance_valid(Caster):
		if Caster.has_method("cast_from"):
			last_known_cast_from = Caster.cast_from() + spell_offset
			return last_known_cast_from
		
		last_known_cast_from = Caster.position + spell_offset
		return Caster.position + spell_offset
	
	return last_known_cast_from

func set_goal():
	if is_instance_valid(Caster) and Caster.has_method("looking_at"):
		last_known_looking_at = Caster.looking_at()
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


func push_caster(push_to_do: Vector2) -> void:
	if is_instance_valid(Caster):
		if Caster.get("speed"):
			Caster.speed += push_to_do
		elif Caster.get("linear_velocity"):
			Caster.linear_velocity += push_to_do


func teleport_caster(relpos:Vector2) -> void:
	if is_instance_valid(Caster):
		Caster.position = relpos
		if Caster.get("speed"):
			Caster.speed = Vector2(0, 0)
		elif Caster.get("linear_velocity"):
			Caster.linear_velocity = Vector2(0, 0)


func vector_from_angle(angle:float, length:float) -> Vector2:
	if "limited" in modifiers:
		return Vector2(cos(angle), sin(angle)) * 2.0
	return Vector2(cos(angle), sin(angle)) * length


func get_caster_position():
	if is_instance_valid(Caster):
		last_known_caster_position = Caster.position
		return Caster.position
	return last_known_caster_position


func get_wand_projectile_speed():
	if is_instance_valid(wand):
		return wand.projectile_speed
	return 5



func duplicate(subresources: bool = false):
	var new = get_script().new()
	new.Caster = self.Caster
	new.spell = self.spell
	new.wand = self.wand
	new.goal = self.goal
	new.goal_offset = self.goal_offset

	new.spell_offset = self.spell_offset

	new.modifiers = self.modifiers


	new.last_known_caster_position = self.last_known_caster_position
	new.last_known_cast_from = self.last_known_cast_from
	new.last_known_looking_at = self.last_known_looking_at
	
	return new
