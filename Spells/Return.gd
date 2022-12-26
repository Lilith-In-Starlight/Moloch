extends Node2D


var CastInfo := SpellCastInfo.new()


func _ready() -> void:
	position = CastInfo.get_caster_position()
	for i in get_tree().get_nodes_in_group("ReturnCastEntities"):
		if is_instance_valid(i.CastInfo.Caster):
			if i.CastInfo.wand == CastInfo.wand and i.CastInfo.Caster == CastInfo.Caster:
				CastInfo.teleport_caster(i.position - CastInfo.Caster.cast_from())
				CastInfo.drain_caster_soul(0.008)
				queue_free()
				i.queue_free()
				break
		else:
			i.queue_free()
			continue
		
		if i.CastInfo.wand == null:
			i.queue_free()
	add_to_group("ReturnCastEntities")
