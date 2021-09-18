extends RigidBody2D


var item :Item
var Player : KinematicBody2D

func _ready():
	$Sprite.texture = item.texture
	Player = get_tree().get_nodes_in_group("Player")[0]

func _process(delta):
	$Sprite.rotation = -rotation
	
	if Player.position.distance_to(position) < 100:
		if Input.is_action_just_pressed("down"):
			Items.player_items.append(item.id)
			queue_free()
