extends RigidBody2D


var spell :Spell
var Player : KinematicBody2D

func _ready():
	$Sprite.texture = spell.texture
	Player = get_tree().get_nodes_in_group("Player")[0]

func _process(delta):
	print("a")
	$Sprite.rotation = -rotation
	$Sprite.texture = spell.texture
	if Player.position.distance_to(position) < 50:
		if Input.is_action_just_pressed("down"):
			for i in Items.player_spells.size():
				if Items.player_spells[i] == null:
					Items.player_spells[i] = spell
					queue_free()
					break
