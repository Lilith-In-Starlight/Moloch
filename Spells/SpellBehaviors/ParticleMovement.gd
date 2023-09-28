extends Node

class_name ParicleMovement

signal request_death()
signal request_movement(delta)
signal collision_happened(collider, collision_point, collision_normal)

var velocity :Vector2 = Vector2(0,0)
var raycast : ShapeCast2D

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

func _ready() -> void:
	if shape == null:
		shape = Items.default_circle_radius_six
	spellcastinfo = get_parent().CastInfo
	if use_wand_speed: velocity = get_initial_velocity()
	else: velocity = Vector2.RIGHT.rotated(get_initial_velocity().angle()) * velocity.length()
	raycast = ShapeCast2D.new()
	raycast.shape = shape
	raycast.collision_mask = 91
	raycast.enabled = false
	get_parent().add_child(raycast)
	collision_normal_cast = RayCast2D.new()
	collision_normal_cast.enabled = false
	collision_normal_cast.collision_mask = 91
	get_parent().add_child(collision_normal_cast)
	if spellcastinfo.modifiers.has("limited"):
		velocity = Vector2.ZERO
	if spellcastinfo.modifiers.has("down_gravity"):
		gravity = 500
	if spellcastinfo.modifiers.has("up_gravity"):
		gravity = -500
	if spellcastinfo.modifiers.has("acceleration"):
		speed_multiplier *= 1.1
		if velocity.length() < 0.01:
			velocity = (spellcastinfo.goal - get_parent().position).normalized() * 10
	if spellcastinfo.modifiers.has("impulse"):
		if velocity.length() < 0.01:
			velocity = (spellcastinfo.goal - get_parent().position).normalized() * 200
			
	velocity = velocity.rotated(spellcastinfo.angle_offset)


func set_up_to(node: Node2D):
	connect("request_death", node, "_on_request_death")
	connect("request_movement", node, "_on_request_movement")
	


func _physics_process(delta: float) -> void:
	if max_distance > 0 and distance_traveled + (velocity * delta).length() > max_distance:
		velocity = velocity.normalized() * (max_distance - distance_traveled) / delta
	
	if bounces >= max_bounces and max_bounces > 0:
		emit_signal("request_death")
		return
	
	elif distance_traveled >= max_distance and max_distance > 0:
		emit_signal("request_death")
		return
	
	velocity *= speed_multiplier * delta * 60
	
	if spellcastinfo.modifiers.has("orthogonal"):
		if velocity.length() != 0.0:
			var angle = abs(velocity.angle())
			var traangle = velocity.angle()
			if angle <= PI/8:
				velocity = Vector2.RIGHT.rotated(0) * velocity.length()
			elif angle <= 3 * PI/8:
				velocity = Vector2.RIGHT.rotated(2 * PI/8 * sign(traangle)) * velocity.length()
			elif angle <= 5 * PI/8:
				velocity = Vector2.RIGHT.rotated(4 * PI/8 * sign(traangle)) * velocity.length()
			elif angle <= 7 * PI/8:
				velocity = Vector2.RIGHT.rotated(6 * PI/8 * sign(traangle)) * velocity.length()
			else:
				velocity = Vector2.RIGHT.rotated(8 * PI/8 * sign(traangle)) * velocity.length()
	
	raycast.target_position = velocity * delta
	raycast.force_shapecast_update()
	
	if just_cast:
		while raycast.is_colliding() and raycast.get_collider(0) == spellcastinfo.Caster and velocity.length() < 350.0:
			raycast.add_exception(spellcastinfo.Caster)
			raycast.force_shapecast_update()
		raycast.clear_exceptions()
		just_cast = false
	
	var movement_delta := velocity * delta
	
	if raycast.is_colliding():
		var coll_delta = movement_delta * raycast.get_closest_collision_unsafe_fraction() 
		coll_delta = coll_delta.normalized() * (coll_delta.length() + shape.radius * 2.0)
		if do_bounces or limit_movement_to_collision:
			movement_delta = movement_delta * raycast.get_closest_collision_safe_fraction()
		
		
		
		bounces += 1
		var normal := get_collision_normal(movement_delta, coll_delta)
		if do_bounces and normal != Vector2.ZERO:
			emit_signal("collision_happened", raycast.get_collider(0), get_parent().global_position + coll_delta, normal)
			velocity = velocity.bounce(normal)
	else:
		velocity.y += gravity * delta
	
	emit_signal("request_movement", movement_delta)
	distance_traveled += movement_delta.length()


func get_initial_velocity() -> Vector2:
	if is_instance_valid(spellcastinfo.wand):
		return (spellcastinfo.goal - get_parent().position).normalized() * (spellcastinfo.get_wand_projectile_speed() * 60.0)
	return (spellcastinfo.goal - get_parent().position).normalized() * 300.0


func get_collision_normal(delta: Vector2, collpoint: Vector2) -> Vector2:
	collision_normal_cast.position = delta
	collision_normal_cast.cast_to = (raycast.get_collision_point(0) - get_parent().global_position)
	collision_normal_cast.force_raycast_update()
	if collision_normal_cast.is_colliding():
		return collision_normal_cast.get_collision_normal()
	else:
		return raycast.get_collision_normal(0)
