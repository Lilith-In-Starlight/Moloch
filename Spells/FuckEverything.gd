extends Node2D


var CastInfo := SpellCastInfo.new()


func _ready() -> void:
	CastInfo.set_position(self)
	queue_free()
	var n := preload("res://Particles/Explosion.tscn").instance()
	n.area_of_effect = 80
	n.position = position
	get_parent().add_child(n)
