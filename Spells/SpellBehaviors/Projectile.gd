extends Resource

class_name ProjectileBehavior

var first_time := true
var velocity := Vector2()

func move(gravity: float, cast_info, external_forces: Vector2 = Vector2(0, 0)):
	var output: Vector2
	velocity += external_forces
	
	var gravity_vec := Vector2(0, gravity)
	if "down_gravity" in cast_info.modifiers and gravity_vec.y < 0.5:
		gravity_vec.y = 0.5
	elif "up_gravity" in cast_info.modifiers and gravity_vec.y > -0.5:
		gravity_vec.y = -0.5
	elif "up_gravity" in cast_info.modifiers and "down_gravity" in cast_info.modifiers:
		gravity_vec.y = 0
		
	if !first_time:
		velocity += gravity_vec
		
		if "acceleration" in cast_info.modifiers:
			velocity += (cast_info.goal - cast_info.get_position()).normalized() * 2
	output = velocity
	
	if "orthogonal" in cast_info.modifiers:
		var given_vel := velocity
		var normalized := velocity.normalized()
		if normalized.x > 0.3:
			normalized.x = 1
		elif normalized.x < -0.3:
			normalized.x = -1
		else: normalized.x = 0
		if normalized.y > 0.3:
			normalized.y = 1
		elif normalized.y < -0.3:
			normalized.y = -1
		else: normalized.y = 0
		output = normalized.normalized() * velocity.length()
	
	
	first_time = false
	return output


func get_initial_velocity(entity: Node2D):
	if is_instance_valid(entity.CastInfo.wand):
		return (entity.CastInfo.goal - entity.position).normalized() * (entity.CastInfo.get_wand_projectile_speed())
	return (entity.CastInfo.goal - entity.position).normalized() * 5
