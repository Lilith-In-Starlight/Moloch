extends Reference

class_name AreaBehavior

var projectile_side := ProjectileBehavior.new()
var size_mult := 1


func get_initial_velocity(entity: Node2D):
	if not "impulse" in entity.CastInfo.modifiers:
		return Vector2(0, 0)
	if is_instance_valid(entity.CastInfo.wand):
		return (entity.CastInfo.goal - entity.position).normalized() * (entity.CastInfo.get_wand_projectile_speed())
	return (entity.CastInfo.goal - entity.position).normalized() * 5
