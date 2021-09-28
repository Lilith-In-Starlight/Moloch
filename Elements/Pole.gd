tool
extends Node2D

export var size := 5

func _ready():
	if not Engine.editor_hint:
		$Poles.scale.y = 0.5 * size
		$Area/KinematicBody2D.shape = RectangleShape2D.new()
		$Area/KinematicBody2D.shape.extents = Vector2(6, 4 * size + 2)
		$Area/KinematicBody2D.position = Vector2(0, 4 * size)
		set_process(false)

func _process(delta):
	$Poles.scale.y = 0.5 * size

func _on_body_entered(body):
	if body.has_method("enable_pole"):
		body.enable_pole(position.x)


func _on_body_exited(body):
	if body.has_method("disable_pole"):
		body.disable_pole()
