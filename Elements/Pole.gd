tool
extends Node2D

export var size := 5

var Map :TileMap

func _ready():
	if not Engine.editor_hint:
		$Poles.scale.y = 0.5 * size
		$Area/KinematicBody2D.shape = RectangleShape2D.new()
		$Area/KinematicBody2D.shape.extents = Vector2(6, 4 * size + 2)
		$Area/KinematicBody2D.position = Vector2(0, 4 * size)
		$VisibilityEnabler2D.rect = Rect2(-6,0,12,8*size)
		Map = get_tree().get_nodes_in_group("World")[0]

func _process(_delta):
	if Engine.editor_hint:
		$Poles.scale.y = 0.5 * size
	else:
		if Map.get_cellv(Map.world_to_map(position) + Vector2(0, -1))  == -1 and Map.get_cellv(Map.world_to_map(position) + Vector2(0, size + 1)) == -1:
			var n :RigidBody2D = preload("res://Elements/Falling/FallingPole.tscn").instance()
			n.get_node("CollisionShape2D").shape = RectangleShape2D.new()
			n.get_node("CollisionShape2D").shape.extents = Vector2(2, 4 * size)
			n.apply_impulse(Vector2(0, 4*size), Vector2(0, -120))
			n.get_node("Sprite").scale.y = 0.5 * size
			n.position = position + Vector2(0, 4 * size)
			get_parent().add_child(n)
			for i in $Area.get_overlapping_bodies():
				_on_body_exited(i)
			queue_free()
	

func _on_body_entered(body):
	if body.has_method("enable_pole"):
		body.enable_pole(position.x)


func _on_body_exited(body):
	if body.has_method("disable_pole"):
		body.disable_pole()
