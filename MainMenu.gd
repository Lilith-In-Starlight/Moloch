extends Control

func _ready():
	$Animations.play("License")


func _on_NewRun_pressed():
	$Animations.play("Fadein")


func _on_Exit_pressed():
	get_tree().quit()


func _on_animation_finished(anim_name):
	if anim_name == "Fadein":
		get_tree().change_scene("res://Game.tscn")
