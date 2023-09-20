extends Node

class_name ParicleMovement

signal request_death()
signal request_movement(delta)
signal collision_happened(collider, collision_point, collision_normal)

var velocity := Vector2(0,0)
var raycast : RayCast2D

var bounces := 0
var max_bounces := 1
var do_bounces := true

var distance_traveled := 0.0
var max_distance := -1.0
var gravity := 200.0

var speed_multiplier := 1.0
var spellcastinfo : SpellCastInfo

func _ready() -> void:
	spellcastinfo = get_parent().CastInfo
	raycast = RayCast2D.new()
	raycast.collision_mask = 91
	get_parent().add_child(raycast)
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
	
	
	raycast.cast_to = velocity * delta
	raycast.force_raycast_update()
	
	
	var movement_delta := velocity * delta
	if raycast.is_colliding():
		emit_signal("collision_happened", raycast.get_collider(), raycast.get_collision_point(), raycast.get_collision_normal())
		if do_bounces:
			movement_delta = raycast.get_collision_point() - raycast.global_position - velocity.normalized()
			bounces += 1
			if raycast.get_collision_normal().is_normalized():
				velocity = velocity.bounce(raycast.get_collision_normal())
			else:
				velocity *= -1
	else:
		velocity.y += gravity * delta
	
	emit_signal("request_movement", movement_delta)
	distance_traveled += movement_delta.length()
