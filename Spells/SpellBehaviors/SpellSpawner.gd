extends Node

class_name SpellSpawner

signal finished()

var spell :PackedScene
var interval := 0.02
var amount := 16
var rotation := 0.0
var current_rotation := 0.0
var use_spell_as_caster := false


func spawn():
	for i in amount:
		var new_spell := spell.instance()
		new_spell.CastInfo = get_parent().CastInfo.duplicate()
		new_spell.CastInfo.angle_offset = current_rotation
		if use_spell_as_caster:
			new_spell.CastInfo.position_caster = self
		get_parent().get_parent().add_child(new_spell)
		current_rotation += rotation
		if amount > 1:
			yield(get_tree().create_timer(interval), "timeout")
	emit_signal("finished")


func _on_collision_happened(_collider, _point, _normal) -> void:
	spawn()


func cast_from():
	return get_parent().global_position

