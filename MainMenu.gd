extends Control

func _ready():
	$Animations.play("License")


func _on_NewRun_pressed():
	if not $LineEdit.text == "":
		Items.custom_seed = hash($LineEdit.text)
		if Items.custom_seed == 0:
			Items.custom_seed = 1
		Items.WorldRNG.seed = Items.custom_seed
		Items.LootRNG.seed = Items.custom_seed*2
		print("Randomizer seed: ", Items.custom_seed)
	else:
		Items.WorldRNG.randomize()
		Items.LootRNG.seed = Items.WorldRNG.seed*2
	Items.reset_player()
	$Animations.play("Fadein")


func _on_Exit_pressed():
	get_tree().quit()


func _on_animation_finished(anim_name):
	if anim_name == "Fadein":
		get_tree().change_scene("res://Game.tscn")
