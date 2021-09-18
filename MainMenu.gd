extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Animations.play("License")


func _on_NewRun_pressed():
	$Animations.play("Fadein")


func _on_Exit_pressed():
	get_tree().quit()


func _on_animation_finished(anim_name):
	if anim_name == "Fadein":
		get_tree().change_scene("res://Game.tscn")
