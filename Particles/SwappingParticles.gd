extends Node2D


const DUST := preload("res://Particles/MagicDust.tscn")


func _ready() -> void:
	for i in 360/3:
		var a := deg2rad(i)
		var n := DUST.instance()
		n.position = Vector2(cos(a * 3), sin(a * 3)) * (64 + randf()*6)
		add_child(n)

