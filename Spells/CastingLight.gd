extends RayCast2D


var CastInfo := SpellCastInfo.new()



func _ready() -> void:
	CastInfo.set_position(self)
	var angle := CastInfo.get_angle(self)
	cast_to = Vector2(cos(angle), sin(angle)) * 200.0
	force_raycast_update()
	var rel_dist := cast_to
	if is_colliding():
		var point := get_collision_point()
		rel_dist = point - position
		var collider := get_collider()
		if collider.has_method("health_object"):
			collider.health_object().poke_hole(1, CastInfo.Caster)
	
	$Line2D.points[1] = rel_dist
	CastInfo.wand.spell_offset = rel_dist * 0.5


func _on_Timer_timeout() -> void:
	queue_free()
