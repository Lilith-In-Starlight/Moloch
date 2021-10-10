extends RayCast2D


var CastInfo := SpellCastInfo.new()

func _ready() -> void:
	CastInfo.set_position(self)
	CastInfo.set_goal()
	var angle := CastInfo.get_angle(self)
	cast_to = Vector2(cos(angle), sin(angle)) * 500.0
	force_raycast_update()
	var goal := cast_to
	if is_colliding():
		print(get_collision_normal())
		goal = (get_collision_point() - position) + get_collision_normal()*Vector2(3,10.5)
	CastInfo.teleport_caster(goal)
	queue_free()
	
