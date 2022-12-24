extends KinematicBody2D


var frames := 0
var rotate := 0.0
var gravity := 0.0


var CastInfo := SpellCastInfo.new()
var spell_behavior := ProjectileBehavior.new()

func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.goal.angle_to_point(position)
	spell_behavior.velocity = (CastInfo.goal - position).normalized() * CastInfo.projectile_speed * 60
	
	if CastInfo.Caster.has_method("health_object"):
		CastInfo.heat_caster((-12.0 - randf() * 6.0) * -0.2)


func _physics_process(delta):
	for body in $Area.get_overlapping_bodies():
		if not body == self:
			_on_body_entered(body)
	
	spell_behavior.velocity = move_and_slide(spell_behavior.move(10.0, CastInfo))
	frames += 1

func _on_body_entered(body):
	if body.has_method("health_object"):
		if (is_instance_valid(CastInfo.Caster) and (body != CastInfo.Caster or frames >= 3)) or not is_instance_valid(CastInfo.Caster):
			body.health_object().temp_change(-12.0 - randf() * 6.0, CastInfo.Caster)
			queue_free()
	elif body.is_in_group("World"):
		queue_free()
