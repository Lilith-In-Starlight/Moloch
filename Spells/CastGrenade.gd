extends RigidBody2D


var CastInfo := SpellCastInfo.new()
var angle := 0.0
var wand :Wand


func _ready() -> void:
	wand.connect("finished_casting", self, "_on_wand_finished")
	CastInfo.set_position(self)
	CastInfo.set_goal()
	angle = CastInfo.get_angle(self)
	linear_velocity = Vector2(cos(angle), sin(angle)) * 200.0


func _on_timeout() -> void:
	wand.run(self)
	visible = false


func _on_wand_finished():
	queue_free()


func looking_at():
	return linear_velocity + position


func cast_from():
	return position


func _draw() -> void:
	draw_circle(Vector2(0,0), 4, ColorN("white"))


