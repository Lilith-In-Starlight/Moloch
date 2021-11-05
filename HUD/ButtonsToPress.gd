extends Node2D


onready var Animations := $Tween


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Animations.stop_all()
		Animations.interpolate_property($Control, "modulate", $Control.modulate, Color(1.0,1.0,1.0,1.0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		Animations.start()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		Animations.stop_all()
		Animations.interpolate_property($Control, "modulate", $Control.modulate, Color(1.0,1.0,1.0,0.0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		Animations.start()
