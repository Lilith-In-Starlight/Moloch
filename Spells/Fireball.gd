extends KinematicBody2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := ProjectileBehavior.new()

var frames := 0
var rotate := 0.0

var time := 0.0

func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.goal.angle_to_point(position)
	spell_behavior.velocity = spell_behavior.get_initial_velocity(self) * 60
	CastInfo.heat_caster((-12.0 - randf() * 6.0) * 0.2)

func _physics_process(delta):
	for body in $Area.get_overlapping_bodies():
		if not body == self:
			_on_body_entered(body)
	
	
	spell_behavior.velocity = move_and_slide(spell_behavior.move(1.0, CastInfo))
	frames += 1
	time += delta
	if time > 12.0:
		queue_free()

func _on_body_entered(body):
	if body.has_method("health_object"):
		if (is_instance_valid(CastInfo.Caster) and (body != CastInfo.Caster or frames >= 3)) or not is_instance_valid(CastInfo.Caster):
			body.health_object().temp_change(12.0 + randf() * 6.0, CastInfo.Caster)
			body.health_object().add_effect("onfire")
			queue_free()
	elif body.is_in_group("World"):
		queue_free()
