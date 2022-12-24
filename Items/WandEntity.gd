extends RigidBody2D


var wand :Wand
var Player : KinematicBody2D

func _ready():
	$Sprite.render_wand(wand)
	Player = get_tree().get_nodes_in_group("Player")[0]

func _process(_delta):
	$Sprite.render_wand(wand)
	$Sprite.rotation = -rotation
	
	if Player.position.distance_to(position) < 50:
		if Input.is_action_just_pressed("down"):
			if Items.player_wands.size() < 6:
				Items.player_wands.append(wand)
				wand.connect("casting_spell", get_tree().get_nodes_in_group("GameNode")[0], "_on_casting_spell")
				Items.add_child(wand)
				queue_free()
