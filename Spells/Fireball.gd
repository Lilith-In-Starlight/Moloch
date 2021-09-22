extends KinematicBody2D


var Caster :Node2D
var goal :Vector2
var frames := 0
var rotate := 0.0

func _ready():
	rotate = goal.angle_to_point(Caster.position)

func _physics_process(delta):
	if frames < 3:
		for body in $Area.get_overlapping_bodies():
			if not body == self:
				_on_body_entered(body)
	
	
	move_and_slide(Vector2(sin(rotate), cos(rotate))*600)
	frames += 1

func _on_body_entered(body):
	if body.has_method("health_object"):
		if (is_instance_valid(Caster) and (body != Caster or frames >= 3)) or not is_instance_valid(Caster):
			body.health_object().temp_change(5.0 + randf() * 3.0)
	queue_free()