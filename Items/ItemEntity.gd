extends RigidBody2D


var item :Item
var Player : KinematicBody2D

func _ready():
	$Sprite.texture = item.texture
	Player = get_tree().get_nodes_in_group("Player")[0]

func _process(_delta):
	$Sprite.rotation = -rotation
	
	if Player.position.distance_to(position) < 50:
		if Input.is_action_just_pressed("pickup_item"):
			Items.add_item(item.id)
			Items.last_pickup = item
			queue_free()
