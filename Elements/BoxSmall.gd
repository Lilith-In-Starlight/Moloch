extends RigidBody2D


func _ready():
	match Items.WorldRNG.randi()%3:
		1:
			$Sprite.texture = preload("res://Sprites/Elements/BoxSmall2.png")
		2:
			$Sprite.texture = preload("res://Sprites/Elements/Vase.png")
