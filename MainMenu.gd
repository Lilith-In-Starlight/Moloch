extends Control

class MenuOption:
	var option_name := ""
	var func_ref :FuncRef = null
	var menu_dest := ""
	var func_args := []

class MenuSetting:
	var setting_name := ""
	var value := 0
	var enabled := false
	var slider := false
	var config := ""


const MolochTheme := preload("res://Themes/Theme.tres")

onready var Animations := $Animations
onready var SeedLineEdit := $MainMenu/LineEdit


var menu := "main_menu"

var viewing_achievements := false

var changing_key := ""

var changed_keys := {}

var random_noise := OpenSimplexNoise.new()


func _ready():
	Animations.play("License")
	$MainMenuContainer/NewRunButton.grab_focus()
	$SettingsMenuContainer/AccessibleFontCheckbox.pressed = Config.use_accessible_font
	$SettingsMenuContainer/DamageColorsCheckbox.pressed = Config.damage_visuals
	$SettingsMenuContainer/MouseSensitivityContainer/Slider.value = Config.camera_smoothing


func _process(delta: float) -> void:
	$Symbol/SymbolGlow.modulate.a = 0.1 + random_noise.get_noise_1d(Engine.get_frames_drawn() * 3.0) * 0.05
	$Symbol.material.set_shader_param("var", 1.0 + random_noise.get_noise_1d(Engine.get_frames_drawn() * 3.0) * 0.05)
	$Symbol/Smoke.texture.noise_offset.y += 0.5
	$Symbol/Smoke.texture.noise.persistence = 0.6 + sin(Engine.get_frames_drawn() * 0.0001) * 0.1
	$Symbol/Smoke.texture.noise.lacunarity = 1.9 + sin(Engine.get_frames_drawn() * 0.0001) * 0.2
	
	$SettingsMenuContainer/MouseSensitivityContainer/Label.text = "Mouse Sensitivity: " + str(Config.camera_smoothing)
	
	$ControlSettings/Controls/Movement/UpKey.text = "Move Up: " + get_action_text("up")
	$ControlSettings/Controls/Movement/DownKey.text = "Move Down: " + get_action_text("down")
	$ControlSettings/Controls/Movement/MoveLeft.text = "Move Left: " + get_action_text("left")
	$ControlSettings/Controls/Movement/MoveRight.text = "Move Left: " + get_action_text("right")
	$ControlSettings/Controls/Movement/JumpKey.text = "Jump: " + get_action_text("jump")
	
	
	$ControlSettings/Controls/Interaction/InstantlyDie.text = "Instantly Die: " + get_action_text("instant_death")
	$ControlSettings/Controls/Interaction/Interact.text = "Interact: " + get_action_text("interact_world")
	$ControlSettings/Controls/Interaction/UseWand.text = "Use Wand: " + get_action_text("Interact1")
	$ControlSettings/Controls/Interaction/DropWand.text = "Drop Wand: " + get_action_text("Interact2")
	$ControlSettings/Controls/Interaction/PickupItem.text = "Pick Up Items: " + get_action_text("pickup_item")
	
	$ControlSettings/Actions/Save.disabled = changed_keys.empty()
	
	if changed_keys.empty():
		$ControlSettings/Actions/Back.text = "Go Back"
	else:
		$ControlSettings/Actions/Back.text = "Regret Changes"
	


func _input(event: InputEvent) -> void:
	if changing_key != "":
		if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
			changed_keys[changing_key] = event
			changing_key = ""


func proceed_keybinds():
	for action in changed_keys:
		if changed_keys[action] is InputEventKey:
			Config.keyboard_binds[action] = [changed_keys[action].scancode, "key"]
		elif changed_keys[action] is InputEventMouseButton:
			Config.keyboard_binds[action] = [changed_keys[action].button_index, "click"]
	
	changed_keys = {}
	Config.process_keybinds()
	Config.save_config()


func start_new_run() -> void:
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


func _on_animation_finished(anim_name) -> void:
	if anim_name == "Fadein":
		get_tree().change_scene("res://Game.tscn")


func make_menu_option(n:String, m:="",f:FuncRef=null, func_args := []) -> MenuOption:
	var new_option := MenuOption.new()
	new_option.option_name = n
	new_option.menu_dest = m
	new_option.func_ref = f
	new_option.func_args = func_args
	return new_option


func make_menu_setting(n:String, v, config:String) -> MenuSetting:
	var new_option := MenuSetting.new()
	new_option.setting_name = n
	new_option.config = config
	if v is int:
		new_option.value = v
		new_option.slider = true
	elif v is bool:
		new_option.enabled = v
		new_option.slider = false
	return new_option


func toggle(Child:CheckBox, menu_setting:MenuSetting):
	menu_setting.enabled = !menu_setting.enabled
	Child.pressed = menu_setting.enabled
	change_config_setting(menu_setting.config, menu_setting)


func slide(Child:ToolButton, menu_setting:MenuSetting, amount:int) -> void:
	if menu_setting.slider:
		menu_setting.value = menu_setting.value + amount
		if menu_setting.value < 0:
			menu_setting.value = 12
		menu_setting.value %= 13
		Child.text = menu_setting.setting_name + ": " + str(menu_setting.value)
		change_config_setting(menu_setting.config, menu_setting)


func change_config_setting(config_setting:String, setting:MenuSetting):
	match config_setting:
		"idb":
			Config.instant_death_button = setting.enabled
		"dv":
			Config.damage_visuals = setting.enabled
		"joys":
			Config.joystick_sensitivity = setting.value
		"camsense":
			Config.camera_smoothing = setting.value
		"uaf":
			Config.use_accessible_font = setting.enabled
	Config.save_config()


func show_achievements():
	$MainMenuContainer.visible = false
	$Achievements.visible = true
	$MainMenu.visible = false
	$Achievements/MainMenuButton.grab_focus()


func start_changing_key(key) -> void:
	changing_key = key


func get_action_text(action:String):
	if not action in changed_keys:
		for i in InputMap.get_action_list(action):
			if i is InputEventKey:
				return Config.get_input_name([i.scancode, "key"])
			elif i is InputEventMouseButton:
				return Config.get_input_name([i.button_index, "click"])
	else:
		var i = changed_keys[action]
		if i is InputEventKey:
			return Config.get_input_name([i.scancode, "key"]) + " [*]"
		if i is InputEventMouseButton:
			return Config.get_input_name([i.button_index, "click"]) + " [*]"


func reset_focus(Child:Control) -> void:
	Child.release_focus()


func quit_game():
	get_tree().quit()


func set_to_main_menu() -> void:
	$MainMenu.visible = true
	$MainMenuContainer.visible = true
	if $Achievements.visible:
		$Achievements.visible = false
		$MainMenuContainer/AchievementsButton.grab_focus()
	elif $SettingsMenuContainer.visible:
		$SettingsMenuContainer.visible = false
		$MainMenuContainer/SettingsButton.grab_focus()


func view_settings() -> void:
	$MainMenuContainer.visible = false
	$SettingsMenuContainer.visible = true
	$MainMenu.visible = false
	$SettingsMenuContainer/MouseSensitivityContainer/Slider.grab_focus()


func set_damage_colors(button_pressed: bool) -> void:
	Config.damage_visuals = button_pressed
	Config.save_config()


func set_accessible_font(button_pressed: bool) -> void:
	Config.use_accessible_font = button_pressed
	Config.save_config()


func set_mouse_sensitivity(value: float) -> void:
	Config.camera_smoothing = value
	Config.save_config()


func view_controls() -> void:
	$SettingsMenuContainer.visible = false
	$ControlSettings.visible = true
	$ControlSettings/Controls.current_tab = 0
	$ControlSettings/Controls/Movement/UpKey.grab_focus()


func regret_and_go_back():
	if changed_keys.empty():
		$SettingsMenuContainer.visible = true
		$ControlSettings.visible = false
		$SettingsMenuContainer/ControlsButton.grab_focus()
	
	changed_keys = {}
