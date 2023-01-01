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
	


#func _input(event: InputEvent) -> void:
#	if event is InputEventMouseButton and event.is_pressed():
#		SeedLineEdit.release_focus()
#	if changing_key == "":
#		if (event is InputEventKey or event is InputEventJoypadButton) and event.is_pressed():
#			var current_selection = menus[current_menu][current_menu_pos()]
#			var action := ""
#			if not SeedLineEdit.has_focus() or event is InputEventJoypadButton:
#				for i in ["up", "down", "left", "right", "jump"]:
#					for j in ["", "scroll", "scroll_"]:
#						if InputMap.has_action(j + i) and Input.is_action_just_pressed(j + i):
#							action = i
#							break
#			else:
#				if event is InputEventKey and event.scancode == KEY_ESCAPE:
#					SeedLineEdit.release_focus()
#			if not viewing_achievements:
#				match action:
#					"up":
#						set_current_pos(current_menu_pos() - 1)
#						if current_menu_pos() < 0:
#							set_current_pos(menus[current_menu].size()-1)
#					"down":
#						set_current_pos((current_menu_pos() + 1) % menus[current_menu].size())
#					"jump":
#						if current_selection is MenuOption:
#							if current_selection.menu_dest != "":
#								set_menu(current_selection.menu_dest)
#								current_menu_pos()
#							elif current_selection.func_ref != null:
#								if current_selection.func_args.empty():
#									current_selection.func_ref.call_func()
#								else:
#									current_selection.func_ref.call_funcv(current_selection.func_args)
#						else:
#							if not current_selection.slider:
#								toggle($MenuContainer.get_child(current_menu_pos()), current_selection)
#					"left":
#						if current_selection is MenuSetting:
#							slide($MenuContainer.get_child(current_menu_pos()), current_selection, -1)
#					"right":
#						if current_selection is MenuSetting:
#							slide($MenuContainer.get_child(current_menu_pos()), current_selection, 1)
#			else:
#				if (event is InputEventKey and not event.scancode in [KEY_ALT, KEY_SUPER_L, KEY_MASK_META, KEY_SHIFT, KEY_S, KEY_W]) or event is InputEventJoypadButton:
#					viewing_achievements = false
#	else:
#		if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
#			changed_keys[changing_key] = event
#			changing_key = ""


func proceed_keybinds():
	for action in changed_keys:
		var list:Array = InputMap.get_action_list(action)
		var new_event:InputEvent = changed_keys[action]
		for event in list:
			if event is InputEventKey or event is InputEventMouseButton:
				InputMap.action_erase_event(action, event)
				break
		InputMap.action_add_event(action, new_event)
	changed_keys = {}
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
	else:
		var i = changed_keys[action]
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
