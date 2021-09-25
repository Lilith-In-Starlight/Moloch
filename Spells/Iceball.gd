extends KinematicBody2D


var Caster :Node2D
var goal :Vector2
var frames := 0
var rotate := 0.0
var gravity := 0.0

func _ready():
	position = Caster.position + Vector2(cos(rotate), sin(rotate))*12
	rotate = goal.angle_to_point(Caster.position)
	if Caster.name == "Player":
		set_collision_mask_bit(0, false)

func _physics_process(delta):
	gravity += delta
	if frames < 3:
		for body in $Area.get_overlapping_bodies():
			if not body == self:
				_on_body_entered(body)
	else:
		set_collision_mask_bit(0, true)
	
	
	move_and_slide(Vector2(cos(rotate), sin(rotate)+gravity)*200)
	frames += 1

func _on_body_entered(body):
	if body.has_method("health_object"):
		if (is_instance_valid(Caster) and (body != Caster or frames >= 6)) or not is_instance_valid(Caster):
			body.health_object().temp_change(-12.0 - randf() * 6.0)
			queue_free()
	elif body.is_in_group("World"):
		queue_free()
