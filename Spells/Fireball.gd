extends KinematicBody2D


var Caster :Node2D
var goal :Vector2
var frames := 0
var rotate := 0.0

func _ready():
	rotate = (goal).angle_to_point(Caster.position)
	position = Caster.position + Vector2(cos(rotate), sin(rotate))*12

func _physics_process(delta):
	for body in $Area.get_overlapping_bodies():
		if not body == self:
			_on_body_entered(body)
	
	move_and_slide(Vector2(cos(rotate), sin(rotate))*200)
	frames += 1

func _on_body_entered(body):
	if body.has_method("health_object"):
		if (is_instance_valid(Caster) and (body != Caster or frames >= 6)) or not is_instance_valid(Caster):
			body.health_object().temp_change(12.0 + randf() * 6.0)
			queue_free()
	elif body.is_in_group("World"):
		queue_free()
