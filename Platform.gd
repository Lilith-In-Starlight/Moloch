tool
extends Node2D


var type := "platform"

export var size := 3

func _ready():
	$KinematicBody2D/StaticBody2D.shape = RectangleShape2D.new()
	$KinematicBody2D/StaticBody2D.shape.extents = Vector2(size*4, 4)
	$KinematicBody2D/StaticBody2D.position = Vector2(size*4, 4)
	$CollisionPolygon2D.polygon = [
			Vector2(0, 0),
			Vector2(size*8, 0),
			Vector2(size*8, 4),
			Vector2(0, 4),
		]

func _process(delta):
	if Engine.editor_hint:
		$KinematicBody2D/StaticBody2D.shape = RectangleShape2D.new()
		$KinematicBody2D/StaticBody2D.shape.extents = Vector2(size*4, 4)
		$KinematicBody2D/StaticBody2D.position = Vector2(size*4, 4)
		$CollisionPolygon2D.polygon = [
			Vector2(0, 0),
			Vector2(size*8, 0),
			Vector2(size*8, 4),
			Vector2(0, 4),
		]
	else:
		set_process(false)
