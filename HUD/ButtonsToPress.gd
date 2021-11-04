extends Node2D


onready var Animations := $Animations


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Animations.play("FadeIn", 0.5)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		Animations.play_backwards("FadeIn", 0.5)
