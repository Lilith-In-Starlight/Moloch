extends Node2D


const DUST := preload("res://Particles/MagicDust.tscn")


func _ready() -> void:
	for i in 360/3:
		var a := deg2rad(i)
		var n := DUST.instance()
		n.position = Vector2(cos(a * 3), sin(a * 3)) * (64 + randf()*6)
		add_child(n)
		
	for i in range(-64/3, 65/3):
		var n := DUST.instance()
		n.position = Vector2(i, i) * 3
		add_child(n)
		n = DUST.instance()
		n.position = Vector2(-i, i) * 3
		add_child(n)

