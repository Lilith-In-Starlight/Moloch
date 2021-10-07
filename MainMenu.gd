extends Control

onready var Animations := $Animations
onready var SeedLineEdit := $LineEdit


func _ready():
	$VisualizeDamage.pressed = Config.damage_visuals
	Animations.play("License")


func _on_NewRun_pressed():
	if not SeedLineEdit.text == "":
		if SeedLineEdit.text.is_valid_integer():
			Items.custom_seed = SeedLineEdit.text as int
		else:
			Items.custom_seed = hash(SeedLineEdit.text)
		if Items.custom_seed == 0:
			Items.custom_seed = 1
		Items.WorldRNG.seed = Items.custom_seed
		Items.LootRNG.seed = Items.custom_seed*2
		print("Randomizer seed: ", Items.custom_seed)
	else:
		Items.WorldRNG.randomize()
		Items.LootRNG.seed = Items.WorldRNG.seed*2
	Items.reset_player()
	Animations.play("Fadein")


func _on_Exit_pressed():
	get_tree().quit()


func _on_animation_finished(anim_name):
	if anim_name == "Fadein":
		get_tree().change_scene("res://Game.tscn")


func _on_VisualizeDamage_pressed() -> void:
	Config.damage_visuals = $VisualizeDamage.pressed
	Config.save_config()
