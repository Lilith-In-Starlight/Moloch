extends Panel


onready var Console := $"../Console"


func _ready() -> void:
	$Settings/VisualizeDamage.connect("pressed", Items.player_health, "_instakill_pressed")
	$Settings/VisualizeDamage.pressed = Config.damage_visuals
	$Settings/InstantDeathButton.pressed = Config.instant_death_button
	$Settings/JoystickSensitivity/Text.text = "Joystick Sensitivity: " + str(Config.joystick_sensitivity)


func _on_DieInstantly_pressed() -> void:
	get_tree().paused = false


func _on_Settings_pressed() -> void:
	$Settings.visible = true
	$Options.visible = false

func _input(event: InputEvent) -> void:
	if not Console.has_focus() and event.is_pressed():
		if event is InputEventKey:
			match event.scancode:
				KEY_ESCAPE:
					get_tree().paused = !get_tree().paused
					visible = get_tree().paused
					$Settings.visible = false
					$Options.visible = true


func _on_Back_pressed() -> void:
	$Settings.visible = false
	$Options.visible = true


func _on_VisualizeDamage_pressed() -> void:
	Config.damage_visuals = $Settings/VisualizeDamage.pressed
	print(Config.damage_visuals)
	Config.save_config()


func _on_InstantDeathButton_pressed() -> void:
	Config.instant_death_button = $Settings/InstantDeathButton.pressed
	Config.save_config()


func _on_JoystickSensitivity_value_changed(value: float) -> void:
	$Settings/JoystickSensitivity/Text.text = "Joystick Sensitivity: " + str(value)
	Config.joystick_sensitivity = value
	Config.save_config()
