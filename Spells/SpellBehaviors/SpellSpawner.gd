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
	if spell_object != null:
		var game_node = get_tree().get_nodes_in_group("GameNode")[0]
		for i in amount:
			var info := WandCastingInfo.new()
			info.spell = spell_object
			info.wand = get_parent().CastInfo.wand
			info.caster = get_parent().CastInfo.Caster
			if use_spell_as_caster:
				info.position_caster = self
			game_node._on_casting_spell(info)
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


func _on_collision_happened(_collider, _point, normal: Vector2) -> void:
	current_rotation = normal.angle()
	spawn()
	
func _on_collision_vel_happened(_collider, _point, normal: Vector2, vel: Vector2) -> void:
	current_rotation = vel.angle()
	spawn()


func cast_from():
	return get_parent().global_position


func looking_at() -> Vector2:
	return Vector2.RIGHT.rotated(current_rotation) * 100 + get_parent().global_position
