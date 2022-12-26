extends RayCast2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := RayBehavior.new()

func _ready() -> void:
	add_child(spell_behavior)
	spell_behavior.ray_setup(self, 500)
	CastInfo.set_position(self)
	CastInfo.set_goal()
	spell_behavior.get_angle(CastInfo.goal, position, CastInfo)
	cast_to = spell_behavior.get_cast_to(CastInfo)
	force_raycast_update()
	var goal := cast_to
	if is_colliding():
		goal = (get_collision_point() - position) + get_collision_normal()*Vector2(3,10.5)
		CastInfo.drain_caster_soul(0.01)
	CastInfo.teleport_caster(goal)
	queue_free()
	
