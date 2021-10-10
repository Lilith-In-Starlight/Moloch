extends KinematicBody2D


var CastInfo := SpellCastInfo.new()

var frames := 0
var rotate := 0.0

func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.goal.angle_to_point(position)
	CastInfo.heat_caster((-12.0 - randf() * 6.0) * 0.2)

func _physics_process(_delta):
	for body in $Area.get_overlapping_bodies():
		if not body == self:
			_on_body_entered(body)
	
	
	move_and_slide(Vector2(cos(rotate), sin(rotate))*200)
	frames += 1

func _on_body_entered(body):
	if body.has_method("health_object"):
		if (is_instance_valid(CastInfo.Caster) and (body != CastInfo.Caster or frames >= 3)) or not is_instance_valid(CastInfo.Caster):
			body.health_object().temp_change(12.0 + randf() * 6.0)
			body.health_object().add_effect("onfire")
			queue_free()
	elif body.is_in_group("World"):
		queue_free()
