extends Line2D

const PARTICLES := preload("res://Particles/MagicDust.tscn")


func _ready() -> void:
	get_parent().get_parent().add_child(preload("res://Spells/SpellBehaviors/SpellTrail.tscn").instance())


func _on_request_movement(delta: Vector2):
	for distance in delta.length() / 5.0:
		var unit := -delta.normalized() * 5.0
		var new_p := PARTICLES.instance()
		new_p.modulate = default_color
		new_p.seconds = 0.5
		new_p.position = unit * distance + get_parent().position
		get_parent().get_parent().add_child(new_p)
		new_p.set_process(true)
#	points = [-delta, Vector2.ZERO]


# 1 / x = spacing / total
# x = total / spacing
