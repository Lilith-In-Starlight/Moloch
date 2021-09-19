extends Node2D


var Player

func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]

func _process(delta):
	if position.distance_to(Player.position) < 20 and Input.is_action_just_pressed("down"):
		$AnimationPlayer.play("Open")
