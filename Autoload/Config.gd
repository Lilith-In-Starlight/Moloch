extends Node

signal achievement_unlocked(achievement)

var config_file:ConfigFile = ConfigFile.new()

# Controller Support
var last_input_was_controller := false

# Accessibility
var damage_visuals := false
var instant_death_button := false
var joystick_sensitivity := 6
var use_accessible_font := false setget set_font
var camera_smoothing := 5

var app_start_time = OS.get_unix_time()

var default_font = preload("res://dpcomic.ttf")
var accessible_font = preload("res://OpenSans-Regular.ttf")
var menu_theme = preload("res://Themes/Theme.tres")
var version_theme = preload("res://Themes/VersionTheme.tres")
var seed_theme = preload("res://Themes/SeedTheme.tres")
var achievo_theme = preload("res://Themes/AchievoTextTheme.tres")
var bigdesctext_theme = preload("res://Themes/BigDescTextTheme.tres")
var smoldesctext_theme = preload("res://Themes/SmolDescTextTheme.tres")
var tooltip_theme = preload("res://Themes/TooltipTheme.tres")

# Tutorial

var tutorial := {
	"healed" : false,
	"seen_info" : false,
}

# Achievements
var achievements := {
	"fun1":false,
	"fun2":false,
	"oof_ouch":false,
	"first_of_many":false,
	"armageddont":false,
	"test":false,
}

var ach_info := {
	"fun1": {
		"text" : "Oh Hey What Does This Do",
		"texture" : preload("res://Sprites/Achievements/OhHeyWhatDoesThisDo.png"),
		"desc" : "Be killed by the side effects of one of your spells"
	},
	"fun2": {
		"text" : "Oh Woah Whats This",
		"texture" : preload("res://Sprites/Achievements/OhWoahWhatsThis.png"),
		"desc" : "Be killed by one of your spells"
	},
	"oof_ouch": {
		"text" : "Oof Ouch My Bones",
		"texture" : preload("res://Sprites/Achievements/OofOuchMyBones.png"),
		"desc" : "Break four legs on the same run"
	},
	"first_of_many": {
		"text" : "First Of Many",
		"texture" : preload("res://Sprites/Achievements/FirstDeath.png"),
		"desc" : "You will die thousands of times"
	},
	"armageddont": {
		"text" : "Armageddon't",
		"texture" : preload("res://Sprites/Achievements/Armageddont.png"),
		"desc" : "Kill an Armageddon Machine"
	},
	"test": {
		"text" : "Blood Thirst",
		"texture" : preload("res://Sprites/Achievements/Trophy.png"),
		"desc" : "This is a test achievement and cannot be obtained"
	},
	
}

var discord : Discord.Core

func _ready() -> void:
	var err := config_file.load("user://config.moloch")
	if err == OK:
		self.damage_visuals = config_file.get_value("config", "damage_visuals", false)
		self.instant_death_button = config_file.get_value("config", "instant_death_button", false)
		self.joystick_sensitivity = config_file.get_value("config", "joystick_sensitivity", 6)
		self.camera_smoothing = config_file.get_value("config", "camera_smoothing", 5)
		self.use_accessible_font = config_file.get_value("config", "accessible_font", false)
		for i in InputMap.get_actions():
			var obtained = config_file.get_value("config", "keybinds_%s"%i, InputMap.get_action_list(i))
			InputMap.action_erase_events(i)
			for j in obtained:
				InputMap.action_add_event(i, j)
		
		var new_dict = config_file.get_value("achievements", "achievements", achievements)
		for i in new_dict:
			achievements[i] = new_dict[i]
		
		new_dict = config_file.get_value("tutorial", "tutorial", tutorial)
		for i in new_dict:
			tutorial[i] = new_dict[i]
		config_file.save("user://config.moloch")
	else:
		save_config()
	
	if Input.get_connected_joypads().size() > 0:
		last_input_was_controller = true
	
	# Eh??
	discord = Discord.Core.new()
	var result: int = discord.create(
		918003339264938035,
		Discord.CreateFlags.NO_REQUIRE_DISCORD
	)

	if result != Discord.Result.OK:
		print(
			"Failed to initialise Discord Core: ",
			result
		)
		discord = null
		return
	print("Initialised core successfully.")
	var act = Discord.Activity.new()
	act.state = "In Menu"
	act.details = "Suffering"
	act.assets.large_image = "logoimage"
	act.assets.large_text = "Optimizing for X"
	act.timestamps.start = app_start_time
	
	discord.get_activity_manager().update_activity(act)


func _process(delta: float) -> void:
	if not discord == null:
		discord.run_callbacks()


func save_config() -> void:
	config_file.set_value("config", "damage_visuals", damage_visuals)
	config_file.set_value("config", "instant_death_button", instant_death_button)
	config_file.set_value("config", "joystick_sensitivity", joystick_sensitivity)
	config_file.set_value("config", "camera_smoothing", camera_smoothing)
	config_file.set_value("config", "accessible_font", use_accessible_font)
	for i in InputMap.get_actions():
		config_file.set_value("config", "keybinds_%s"%i, InputMap.get_action_list(i))
	
	config_file.set_value("achievements", "achievements", achievements)
	config_file.set_value("tutorial", "tutorial", tutorial)
	config_file.save("user://config.moloch")


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		last_input_was_controller = false
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		last_input_was_controller = true


func give_achievement(achievement: String) -> void:
	if achievement in achievements and not achievements[achievement]:
		achievements[achievement] = true
		emit_signal("achievement_unlocked", achievement)
		save_config()


func set_font(value):
	if value:
		menu_theme.default_font.font_data = accessible_font
		menu_theme.default_font.size = 12
		menu_theme.default_font.outline_size = 1.2
		menu_theme.default_font.extra_spacing_top = -2
		achievo_theme.default_font.size = 8
	else:
		menu_theme.default_font.font_data = default_font
		menu_theme.default_font.size = 16
		menu_theme.default_font.outline_size = 2
		menu_theme.default_font.extra_spacing_top = 0
		achievo_theme.default_font.size = 10
	
	version_theme.default_font.font_data = menu_theme.default_font.font_data
	version_theme.default_font.size = menu_theme.default_font.size - 3
	version_theme.default_font.extra_spacing_top = menu_theme.default_font.extra_spacing_top
	
	seed_theme.default_font.font_data = menu_theme.default_font.font_data
	seed_theme.default_font.size = menu_theme.default_font.size - 3
	seed_theme.default_font.extra_spacing_top = seed_theme.default_font.extra_spacing_top
	
	achievo_theme.default_font.font_data = menu_theme.default_font.font_data
	achievo_theme.default_font.extra_spacing_top = menu_theme.default_font.extra_spacing_top
	
	bigdesctext_theme.default_font.font_data = menu_theme.default_font.font_data
	bigdesctext_theme.default_font.extra_spacing_top = menu_theme.default_font.extra_spacing_top
	bigdesctext_theme.default_font.size = menu_theme.default_font.size - 4
	
	smoldesctext_theme.default_font.font_data = menu_theme.default_font.font_data
	smoldesctext_theme.default_font.extra_spacing_top = menu_theme.default_font.extra_spacing_top
	smoldesctext_theme.default_font.size = achievo_theme.default_font.size
	
	tooltip_theme.default_font.font_data = menu_theme.default_font.font_data
	tooltip_theme.default_font.extra_spacing_top = menu_theme.default_font.extra_spacing_top
	tooltip_theme.default_font.size = achievo_theme.default_font.size + 1
	
	use_accessible_font = value
