extends RigidBody2D


var spell :Spell
var Player : KinematicBody2D

func _ready():
	$Sprite.texture = spell.texture
	Player = get_tree().get_nodes_in_group("Player")[0]

func _process(_delta):
	$Sprite.rotation = -rotation
	$ButtonsToPress.rotation = -rotation
	$Sprite.texture = spell.texture
	if Player.position.distance_to(position) < 50:
		if Input.is_action_just_pressed("pickup_item"):
			if Items.player_spells.size() < 6:
				Items.player_spells.append(spell)
				queue_free()
