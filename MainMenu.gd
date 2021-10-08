extends Control

onready var Animations := $Animations
onready var SeedLineEdit := $MainMenu/LineEdit


func _ready():
	$Settings/VisualizeDamage.pressed = Config.damage_visuals
	$Settings/InstantDeathButton.pressed = Config.instant_death_button
	$Settings/JoystickSensitivity/Text.text = "Joystick Sensitivity: " + str(Config.joystick_sensitivity)
	$Settings/JoystickSensitivity.value = Config.joystick_sensitivity
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
	Config.damage_visuals = $Settings/VisualizeDamage.pressed
	Config.save_config()


func _on_InstantDeathButton_pressed() -> void:
	Config.instant_death_button = $Settings/InstantDeathButton.pressed
	Config.save_config()


func _on_JoystickSensitivity_value_changed(value: float) -> void:
	$Settings/JoystickSensitivity/Text.text = "Joystick Sensitivity: " + str(value)
	Config.joystick_sensitivity = value
	Config.save_config()
	


func _on_Settings_pressed() -> void:
	$MainMenu.visible = false
	$Settings.visible = true


func _on_Back_pressed() -> void:
	$MainMenu.visible = true
	$Settings.visible = false
