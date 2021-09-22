extends Node2D

signal level_ended

var Player

func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]
	connect("level_ended", get_tree().get_nodes_in_group("HUD")[0], "_on_level_ended")

func _process(delta):
	if position.distance_to(Player.position) < 20 and Input.is_action_just_pressed("down"):
		$AnimationPlayer.play("Open")


func _on_animation_finished(anim_name):
	emit_signal("level_ended")
