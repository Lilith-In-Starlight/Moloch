extends Node

class_name ParicleMovement

signal request_death()
signal request_movement(delta)
signal collision_happened(collider, collision_point, collision_normal)
signal collision_happened_vel(collider, collision_point, collision_normal, velocity)

var velocity :Vector2 = Vector2(0,0)
var raycast : RayCast2D

var collision_normal_cast: RayCast2D

var bounces := 0
var max_bounces := 1
var do_bounces := true
var limit_movement_to_collision := true

var distance_traveled := 0.0
var max_distance := -1.0
var gravity := 200.0

var speed_multiplier := 1.0
var spellcastinfo : SpellCastInfo
var shape : Shape2D
var spawned_inside := false
var just_cast := true
var use_wand_speed := true
var ortho := false
var collide_with_caster := true
var max_requests := -1
var requests := 0

func _ready() -> void:
	if shape == null:
		shape = Items.default_circle_radius_six
	spellcastinfo = get_parent().CastInfo
	if use_wand_speed: velocity = get_initial_velocity()
	else: velocity = Vector2.RIGHT.rotated(get_initial_velocity().angle()) * velocity.length()
	raycast = RayCast2D.new()
#	raycast.shape = shape
	raycast.collision_mask = 91
	raycast.enabled = false
	get_parent().add_child(raycast)
#	collision_normal_cast = RayCast2D.new()
#	collision_normal_cast.enabled = false
#	collision_normal_cast.collision_mask = 91
#	get_parent().add_child(collision_normal_cast)
	
	var applier :SpellModifierApplier = SpellModifierApplier.new()
	applier.modifiers = spellcastinfo.modifiers.duplicate()
	applier.collision_manager = self
	applier.applied_to = get_parent()
	applier.spellcastinfo = spellcastinfo
	applier.max_bounces = max_bounces
	applier.max_distance = max_distance
	applier.limit_movement_to_collision = limit_movement_to_collision
	applier.max_requests = max_requests
	applier.speed_multiplier = speed_multiplier
	applier.velocity = velocity
	applier.gravity = gravity
	applier.collision_mask = raycast.collision_mask
	applier.ortho = ortho
	
	applier.apply_mods()
	
	max_bounces = applier.max_bounces
	max_distance = applier.max_distance
	max_requests = applier.max_requests
	speed_multiplier = applier.speed_multiplier
	raycast.collision_mask = applier.collision_mask
	limit_movement_to_collision = applier.limit_movement_to_collision
	velocity = applier.velocity
	gravity = applier.gravity
	ortho = applier.ortho
			
	velocity = velocity.rotated(spellcastinfo.angle_offset)
	if !collide_with_caster:
		raycast.add_exception(spellcastinfo.Caster)


func set_up_to(node: Node2D):
	connect("request_death", node, "_on_request_death")
	connect("request_movement", node, "_on_request_movement")
	


func _physics_process(delta: float) -> void:
	var send_collision := false
	
	if max_distance > 0 and distance_traveled + (velocity * delta).length() > max_distance:
		velocity = velocity.normalized() * (max_distance - distance_traveled) / delta
	
	if bounces >= max_bounces and max_bounces > 0:
		emit_signal("request_death")
		return
	
	elif distance_traveled >= max_distance and max_distance > 0:
		emit_signal("request_death")
		return
		
	elif requests >= max_requests and max_requests > 0:
		emit_signal("request_death")
		return
	
	velocity *= speed_multiplier * delta * 60
	
	raycast.cast_to = orthogonalize(velocity * delta)
	raycast.force_raycast_update()
	
	if just_cast:
		if is_instance_valid(spellcastinfo.Caster) and not spellcastinfo.Caster.get("position") == null:
			var distance_decreases := 0
			var cdist :float = get_parent().position.distance_to(spellcastinfo.Caster.position)
			while raycast.is_colliding() and raycast.get_collider() == spellcastinfo.Caster:
				raycast.force_raycast_update()
				get_parent().position += raycast.cast_to.normalized()
				var ndist :float = get_parent().position.distance_to(spellcastinfo.Caster.position)
				if ndist < cdist:
					distance_decreases += 1
				if distance_decreases > 8.0:
					break
				cdist = ndist
		just_cast = false
		
	
	var movement_delta := velocity * delta
	
#	var coll_delta = null
	var normal = null
	
	if raycast.is_colliding():
#		coll_delta = movement_delta * raycast.get_closest_collision_unsafe_fraction() 
#		coll_delta = coll_delta.normalized() * (coll_delta.length() + get_radius_at_angle(coll_delta.angle()).length() * 2.0)
		if do_bounces or limit_movement_to_collision:
			movement_delta = raycast.get_collision_point() - get_parent().position - velocity.normalized() * 1.0
		
		
		bounces += 1
		if do_bounces and raycast.get_collision_normal() != Vector2.ZERO:
			send_collision = true
			velocity = orthogonalize(velocity).bounce(raycast.get_collision_normal())
	else:
		velocity.y += gravity * delta
	
	if orthogonalize(movement_delta).length() < 0.001:
		requests += 1
	emit_signal("request_movement", orthogonalize(movement_delta))
	distance_traveled += orthogonalize(movement_delta).length()
	
	
	if send_collision:
		emit_signal("collision_happened", raycast.get_collider(), raycast.get_collision_point(), raycast.get_collision_normal())
		emit_signal("collision_happened_vel", raycast.get_collider(), raycast.get_collision_point(), raycast.get_collision_normal(), velocity)


func get_initial_velocity() -> Vector2:
	if is_instance_valid(spellcastinfo.wand):
		return (spellcastinfo.goal - get_parent().position).normalized() * (spellcastinfo.get_wand_projectile_speed() * 60.0)
	return (spellcastinfo.goal - get_parent().position).normalized() * 300.0


#func get_collision_normal(delta: Vector2) -> Vector2:
#	collision_normal_cast.cast_to = (raycast.get_collision_point(0) - get_parent().global_position)
#	collision_normal_cast.force_raycast_update()
#	if collision_normal_cast.is_colliding():
#		return collision_normal_cast.get_collision_normal()
#	else:
#		return raycast.get_collision_normal(0)


func orthogonalize(v: Vector2) -> Vector2:
	var vector := v
	if vector.length() != 0.0 and ortho:
		var angle = abs(vector.angle())
		var traangle = vector.angle()
		if angle <= PI/8:
			vector = Vector2.RIGHT.rotated(0) * vector.length()
		elif angle <= 3 * PI/8:
			vector = Vector2.RIGHT.rotated(2 * PI/8 * sign(traangle)) * vector.length()
		elif angle <= 5 * PI/8:
			vector = Vector2.RIGHT.rotated(4 * PI/8 * sign(traangle)) * vector.length()
		elif angle <= 7 * PI/8:
			vector = Vector2.RIGHT.rotated(6 * PI/8 * sign(traangle)) * vector.length()
		else:
			vector = Vector2.RIGHT.rotated(8 * PI/8 * sign(traangle)) * vector.length()
	return vector


#func get_radius_at_angle(angle: float) -> Vector2:
#	if shape is CircleShape2D:
#		return Vector2.RIGHT.rotated(angle)
#	elif shape is RectangleShape2D:
#		var quad_angle = atan(abs(tan(angle)))
#		var corner_angle = atan2(shape.extents.y, shape.extents.x)
#		var vecx = cos(quad_angle)
#		var vecy = sin(quad_angle)
#		if quad_angle < corner_angle:
#			vecx = shape.extents.x / 2.0
#			vecy *= vecx / cos(quad_angle)
#		elif quad_angle > corner_angle:
#			vecy = shape.extents.y / 2.0
#			vecx *= vecy / sin(quad_angle)
#		else:
#			vecx = shape.extents.x / 2.0
#			vecy = shape.extents.y / 2.0
#		return Vector2.RIGHT.rotated(quad_angle) * Vector2(vecx, vecy).length()
#
#	else:
#		return Vector2.RIGHT.rotated(angle) * 100
