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
			for i in Items.player_wands.size():
				if Items.player_wands[i] == null:
					Items.player_wands[i] = wand
					queue_free()
					break
