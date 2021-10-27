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

onready var Animations := $Animations
onready var SeedLineEdit := $MainMenu/LineEdit

var current_menu := "" setget set_menu


var menus := {}

var current_menu_pos := 0


func _ready():
	menus = {
		"main": [
			make_menu_option("New Run", "", funcref(self, "start_new_run")),
			make_menu_option("Settings", "settings"),
			make_menu_option("Exit", "", funcref(get_tree(), "quit")),
			],
		"settings": [
			make_menu_setting("Death Button", Config.instant_death_button),
			make_menu_setting("Damage Colors", Config.damage_visuals),
			make_menu_option("Back", "main"),
			]
	}
	set_menu("main")
	Animations.play("License")
	


func _process(delta: float) -> void:
	$Ball.rect_position = $MenuContainer.get_child(current_menu_pos).rect_global_position - Vector2(0, 12)
	Config.instant_death_button = menus["settings"][0].enabled
	Config.damage_visuals = menus["settings"][1].enabled


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventJoypadButton) and event.is_pressed():
		var action := ""
		for i in ["up", "down", "left", "right", "jump"]:
			for j in ["", "scroll", "scroll_"]:
				if InputMap.has_action(j + i) and Input.is_action_just_pressed(j + i):
					action = i
		match action:
			"left":
				current_menu_pos -= 1
				if current_menu_pos < 0:
					current_menu_pos = menus[current_menu].size()-1
			"right":
				current_menu_pos = (current_menu_pos + 1) % menus[current_menu].size()
			"jump", "down":
				if menus[current_menu][current_menu_pos] is MenuOption:
					var menu_option: MenuOption = menus[current_menu][current_menu_pos]
					if menu_option.menu_dest != "":
						set_menu(menu_option.menu_dest)
						current_menu_pos = 0
					elif menu_option.func_ref != null:
						menu_option.func_ref.call_func()
				else:
					var menu_setting: MenuSetting = menus[current_menu][current_menu_pos]
					print(menu_setting.enabled)
					if menu_setting.slider:
						pass
					else:
						menu_setting.enabled = !menu_setting.enabled
						$MenuContainer.get_child(current_menu_pos).pressed = menu_setting.enabled
					Config.save_config()
	

func set_menu(menu:String) -> void:
	current_menu = menu
	for i in $MenuContainer.get_children():
		i.queue_free()
	for i in menus[menu]:
		if i is MenuOption:
			var new_label := Label.new()
			new_label.text = i.option_name
			$MenuContainer.add_child(new_label)
		elif i is MenuSetting:
			if i.slider:
				var new_slider := Slider.new()
				new_slider.text = i.setting_name
				new_slider.value = i.value
				new_slider.max_value = 12
				$MenuContainer.add_child(new_slider)
			else:
				var new_check := CheckBox.new()
				new_check.text = i.setting_name
				new_check.pressed = i.enabled
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


func make_menu_setting(n:String, v) -> MenuSetting:
	var new_option := MenuSetting.new()
	new_option.setting_name = n
	if v is int:
		new_option.value = v
		new_option.slider = true
	elif v is bool:
		new_option.enabled = v
		new_option.slider = false
	return new_option
