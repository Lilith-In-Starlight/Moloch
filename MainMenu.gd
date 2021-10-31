extends Control

class MenuOption:
	var option_name := ""
	var func_ref :FuncRef = null
	var menu_dest := ""

class MenuSetting:
	var setting_name := ""
	var value := 0
	var enabled := false
	var slider := false
	var config := ""


const MolochTheme := preload("res://Themes/Theme.tres")

onready var Animations := $Animations
onready var SeedLineEdit := $MainMenu/LineEdit

var current_menu := "" setget set_menu


var menus := {}

var current_menu_pos := 0

var viewing_achievements := false


func _ready():
	menus = {
		"main": [
			make_menu_option("New Run", "", funcref(self, "start_new_run")),
			make_menu_option("Settings", "settings"),
			make_menu_option("Exit", "", funcref(get_tree(), "quit")),
			],
		"settings": [
			make_menu_setting("Death Button", Config.instant_death_button, "idb"),
			make_menu_setting("Damage Colors", Config.damage_visuals, "dv"),
			make_menu_setting("Joystick Sensitivity", Config.joystick_sensitivity, "joys"),
			make_menu_option("Back", "main"),
			]
	}
	set_menu("main")
	Animations.play("License")


func _process(delta: float) -> void:
	$Ball.rect_position = $MenuContainer.get_child(current_menu_pos).rect_global_position - Vector2(12, -2)
	Config.instant_death_button = menus["settings"][0].enabled
	Config.damage_visuals = menus["settings"][1].enabled
	
	$GridContainer.visible = viewing_achievements
	$MainMenu.visible = !viewing_achievements
	$MenuContainer.visible = !viewing_achievements
	$Ball.visible = !viewing_achievements


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventJoypadButton) and event.is_pressed():
		var current_selection = menus[current_menu][current_menu_pos]
		var action := ""
		for i in ["up", "down", "left", "right", "jump"]:
			for j in ["", "scroll", "scroll_"]:
				if InputMap.has_action(j + i) and Input.is_action_just_pressed(j + i):
					action = i
		match action:
			"up":
				current_menu_pos -= 1
				if current_menu_pos < 0:
					current_menu_pos = menus[current_menu].size()-1
			"down":
				current_menu_pos = (current_menu_pos + 1) % menus[current_menu].size()
			"jump":
				if current_selection is MenuOption:
					if current_selection.menu_dest != "":
						set_menu(current_selection.menu_dest)
						current_menu_pos = 0
					elif current_selection.func_ref != null:
						current_selection.func_ref.call_func()
				else:
					if not current_selection.slider:
						current_selection.enabled = !current_selection.enabled
						$MenuContainer.get_child(current_menu_pos).pressed = current_selection.enabled
						change_config_setting(current_selection.config, current_selection)
			"left":
				if current_selection is MenuSetting:
					slide($MenuContainer.get_child(current_menu_pos), current_selection, -1)
			"right":
				if current_selection is MenuSetting:
					slide($MenuContainer.get_child(current_menu_pos), current_selection, 1)

func set_menu(menu:String) -> void:
	current_menu = menu
	for i in $MenuContainer.get_children():
		i.queue_free()
	for i in menus[menu]:
		if i is MenuOption:
			var new_label := Label.new()
			new_label.text = i.option_name
			new_label.theme = MolochTheme
			$MenuContainer.add_child(new_label)
			new_label.align = Label.ALIGN_CENTER
		elif i is MenuSetting:
			if i.slider:
				var new_label := Label.new()
				new_label.text = i.setting_name + ": " + str(i.value)
				new_label.theme = MolochTheme
				$MenuContainer.add_child(new_label)
				new_label.align = Label.ALIGN_CENTER
			else:
				var new_check := CheckBox.new()
				new_check.text = i.setting_name
				new_check.pressed = i.enabled
				new_check.theme = MolochTheme
				$MenuContainer.add_child(new_check)


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


func make_menu_option(n:String, m:="",f:FuncRef=null) -> MenuOption:
	var new_option := MenuOption.new()
	new_option.option_name = n
	new_option.menu_dest = m
	new_option.func_ref = f
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


func slide(Child:Label, menu_setting:MenuSetting, amount:int) -> void:
	if menu_setting.slider:
		menu_setting.value = clamp(menu_setting.value + amount, 0, 12)
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
	Config.save_config()
