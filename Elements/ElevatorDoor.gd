extends Node2D

signal level_ended

var Player
export var came_from := false

func _ready():
	if not came_from:
		Player = get_tree().get_nodes_in_group("Player")[0]
		connect("level_ended", get_tree().get_nodes_in_group("HUD")[0], "_on_level_ended")
	else:
		$AnimationPlayer.play_backwards("Open")

func _process(_delta):
	if not came_from:
		if position.distance_to(Player.position) < 30 and Input.is_action_just_pressed("interact_world"):
			$AnimationPlayer.play("Open")
	else:
		$ButtonsToPress.visible = false


func _on_animation_finished(_anim_name):
	if not came_from:
		Items.save_player_data(true, true)
		emit_signal("level_ended")
