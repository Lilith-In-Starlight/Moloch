extends Area2D


var CastInfo := SpellCastInfo.new()
var angle := 0.0
var wand :Wand


func _ready() -> void:
	wand.connect("finished_casting", self, "_on_wand_finished")
	CastInfo.set_position(self)
	CastInfo.set_goal()
	angle = CastInfo.get_angle(self)
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		position = $RayCast2D.get_collision_point() - Vector2(0,2)
	else:
		wand.run(self)


func _on_wand_finished():
	queue_free()


func looking_at():
	return position - Vector2(0, 10)


func cast_from():
	return position


func _draw() -> void:
	draw_circle(Vector2(0,0), 4, ColorN("white"))


func _on_body_entered(body: Node) -> void:
	if body.name != "World":
		wand.run(self)


func health_object() -> Flesh:
	if is_instance_valid(CastInfo.Caster) and CastInfo.Caster.has_method("health_object"):
		return CastInfo.Caster.health_object()
	return Flesh.new()
