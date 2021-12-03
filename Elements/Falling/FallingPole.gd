extends RigidBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var Map = get_tree().get_nodes_in_group("World")[0]
	if Map.level_tile == 1:
		$Sprite.texture = preload("res://Sprites/Elements/BrownPole.png")
