extends RigidBody2D


var wand :Wand
var Player : KinematicBody2D

func _ready():
	$Sprite.render_wand(wand)
	Player = get_tree().get_nodes_in_group("Player")[0]

func _process(_delta):
	$Sprite.render_wand(wand)
	$Sprite.rotation = -rotation
	$ButtonsToPress.rotation = -rotation
	
	if Player.position.distance_to(position) < 50:
		if Input.is_action_just_pressed("pickup_item"):
			if Items.append_player_wand(wand):
				if not Items.get_children().has(wand):
					var err = wand.connect("casting_spell", get_tree().get_nodes_in_group("GameNode")[0], "_on_casting_spell")
					Items.add_child(wand)
				queue_free()
