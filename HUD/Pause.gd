extends Panel


onready var Console := $"../Console"
var finished_gen := false


func _ready() -> void:
	$Options/DieInstantly.connect("pressed", Items.player_health, "_instakill_pressed")
	$Settings/VisualizeDamage.pressed = Config.damage_visuals
	$Settings/InstantDeathButton.pressed = Config.instant_death_button
	$Settings/ScreenShake/Text.text = "Screen Shake: " + str(Config.screen_shake)
	$Settings/CameraSensitivity/Text.text = "Camera Sensitivity: " + str(Config.camera_smoothing)
	$Settings/ScreenShake.value = Config.screen_shake


func _on_DieInstantly_pressed() -> void:
	get_tree().paused = false


func _on_Settings_pressed() -> void:
	$Settings.visible = true
	$Options.visible = false

func _input(event: InputEvent) -> void:
	if not Console.has_focus() and event.is_pressed() and finished_gen:
		if event is InputEventKey:
			match event.scancode:
				KEY_T:
					Items.visible_spells = !Items.visible_spells
				KEY_ESCAPE:
					get_tree().paused = !get_tree().paused and !Items.player_health.dead
					visible = get_tree().paused and !Items.player_health.dead
					$Settings.visible = false
					$Options.visible = true
					if get_tree().paused and Config.discord != null:
						var act = Discord.Activity.new()
						act.state = "Level %s, %s" % [str(Items.level), str(Items.using_seed)]
						act.details = "Paused"
						act.assets.large_image = "logoimage"
						act.assets.large_text = "Optimizing for X"
						act.timestamps.start = Config.app_start_time
						Config.discord.get_activity_manager().update_activity(act)
					


func _on_Back_pressed() -> void:
	$Settings.visible = false
	$Options.visible = true


func _on_VisualizeDamage_pressed() -> void:
	Config.damage_visuals = $Settings/VisualizeDamage.pressed
	Config.save_config()


func _on_InstantDeathButton_pressed() -> void:
	Config.instant_death_button = $Settings/InstantDeathButton.pressed
	Config.save_config()
	
	
func _on_AccessibleFont_pressed() -> void:
	Config.use_accessible_font = $Settings/AccessibleFont.pressed
	Config.save_config()


func _on_JoystickSensitivity_value_changed(value: float) -> void:
	$Settings/JoystickSensitivity/Text.text = "Joystick Sensitivity: " + str(value)
	Config.joystick_sensitivity = value
	Config.save_config()


func _on_World_generated_world() -> void:
	finished_gen = true


func _on_Player_died() -> void:
	get_tree().paused = false
	visible = get_tree().paused
	$Settings.visible = false
	$Options.visible = true


func _on_CameraSensitivity_value_changed(value: float) -> void:
	$Settings/CameraSensitivity/Text.text = "Camera Sensitivity: " + str(value)
	Config.camera_smoothing = value
	Config.save_config()


func _on_MainMenu_pressed() -> void:
	get_tree().change_scene("res://MainMenu.tscn")


func _on_ScreenShake_value_changed(value) -> void:
	$Settings/ScreenShake/Text.text = "Screen Shake: " + str(value)
	Config.screen_shake = value
	Config.save_config()
