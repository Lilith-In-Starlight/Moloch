extends Node

class_name SpellSpawner

signal finished()

var spell :PackedScene = null
var spell_object :Spell
var interval := 0.02
var amount := 16
var rotation := 0.0
var current_rotation := 0.0
var use_spell_as_caster := false
var global_position : Vector2



func spawn():
	if spell_object == null:
		var game_node = get_tree().get_nodes_in_group("GameNode")[0]
		for i in amount:
			game_node._on_casting_spell(spell_object, get_parent().CastInfo.wand, get_parent().CastInfo.caster)
			if amount > 1:
				yield(get_tree().create_timer(interval), "timeout")
	elif spell != null:
		for i in amount:
			global_position = get_parent().global_position
			var new_spell := spell.instance()
			new_spell.CastInfo = get_parent().CastInfo.duplicate()
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
	return global_position


func looking_at() -> Vector2:
	return Vector2.RIGHT.rotated(current_rotation) * 100 + global_position
