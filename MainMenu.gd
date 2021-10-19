extends Control

onready var Animations := $Animations
onready var SeedLineEdit := $MainMenu/LineEdit

var setting_control := -1


func _ready():
	$Settings/VisualizeDamage.pressed = Config.damage_visuals
	$Settings/InstantDeathButton.pressed = Config.instant_death_button
	$Settings/JoystickSensitivity/Text.text = "Joystick Sensitivity: " + str(Config.joystick_sensitivity)
	$Settings/JoystickSensitivity.value = Config.joystick_sensitivity
	Animations.play("License")
	
#	for i in Localization.languages:
#		$MenuButton.add_item(Localization.languages[i]["langname"])
#	_on_updated_language()


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
	$Achievements.visible = false


func _on_Controls_pressed() -> void:
	$Settings.visible = false
	$Controls.visible = true


func _input(event: InputEvent) -> void:
	$Controls/Heal.text = "Heal: " + get_action_text("seal_blood")
	$Controls/Grab.text = "Grab Poles: " + get_action_text("grab")
	$Controls/Shoot.text = "Fire Wand/Select Item: " + get_action_text("Interact1")
	$Controls/Drop.text = "Drop Item: " + get_action_text("Interact2")
	$Controls/Up.text = "Up: " + get_action_text("up")
	$Controls/Down.text = "Down: " + get_action_text("down")
	$Controls/Left.text = "Left: " + get_action_text("left")
	$Controls/Right.text = "Right: " + get_action_text("right")
	$Controls/Jump.text = "Jump: " + get_action_text("jump")
	$Controls/Info.text = "Extra Info: " + get_action_text("see_info")
	$Controls/Death.text = "Instantly Die: " + get_action_text("instant_death")
	for i in $Controls.get_child_count():
		$Controls.get_child(i).modulate = ColorN("white")
	if event is InputEventMouseButton and not event.is_pressed() and event.button_index == 1:
		for i in $Controls.get_child_count():
			$Controls.get_child(i).modulate = ColorN("white")
			if $Controls.get_child(i).pressed and i < 11:
				setting_control = i
				break
	if setting_control != -1:
		$Controls.get_child(setting_control).modulate = ColorN("cyan")
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed() and setting_control != -1:
		var list := []
		var action := ""
		match setting_control:
			0: action = "seal_blood"
			1: action = "grab"
			2: action = "Interact1"
			3: action = "Interact2"
			4: action = "up"
			5: action = "down"
			6: action = "left"
			7: action = "right"
			8: action = "jump"
			9: action = "see_info"
			10: action = "instant_death"
		list = InputMap.get_action_list(action)
		for i in list:
			if i is InputEventKey or i is InputEventMouseButton:
				InputMap.action_erase_event(action, i)
				break
		InputMap.action_add_event(action, event)
		setting_control = -1
		Config.save_config()


func _on_BackControl_pressed() -> void:
	setting_control = -1
	$Settings.visible = true
	$Controls.visible = false


func get_action_text(action:String):
	for i in InputMap.get_action_list(action):
		if i is InputEventKey:
			return OS.get_scancode_string(i.scancode)
		if i is InputEventMouseButton:
			match i.button_index:
				1: return "Left Click"
				2: return "Right Click"
				3: return "Middle Click"
				4: return "Scroll Up"
				5: return "Scroll Down"
				6: return "Scroll Left"
				7: return "Scroll Right"
				8: return "Extra Click 1"
				9: return "Extra Click 2"


func _on_Reset_pressed() -> void:
	InputMap.load_from_globals()
	Config.save_config()


#func update_language(index:int) -> void:
#	var lang = Localization.languages.keys()[index]
#	Localization.current_language = lang
#	_on_updated_language()
#
#
#func _on_updated_language() -> void:
#	$MainMenu/Buttons/NewRun.text = Localization.get_line("play-button")
#	$MainMenu/Buttons/Settings.text = Localization.get_line("settings-button")
#	$MainMenu/Buttons/Exit.text = Localization.get_line("exit-button")
#	$MainMenu/LineEdit.placeholder_text = Localization.get_line("seed-placeholder")
#	$Settings/JoystickSensitivity/Text.text = Localization.get_line("joystick-sensitivity") + str(Config.joystick_sensitivity)


func _on_Achievements_pressed() -> void:
	$Achievements.visible = true
	$MainMenu.visible = false
	$Achievements/Achievos/OhHey.visible = Config.achievements["fun1"]
	$Achievements/Achievos/OhWoah.visible = Config.achievements["fun2"]
