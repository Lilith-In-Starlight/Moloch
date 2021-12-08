extends Node

signal achievement_unlocked(achievement)

var config_file:ConfigFile = ConfigFile.new()

# Controller Support
var last_input_was_controller := false

# Accessibility
var damage_visuals := false
var instant_death_button := false
var joystick_sensitivity := 6

var app_start_time = OS.get_unix_time()

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
		damage_visuals = config_file.get_value("config", "damage_visuals", false)
		instant_death_button = config_file.get_value("config", "instant_death_button", false)
		joystick_sensitivity = config_file.get_value("config", "joystick_sensitivity", 6)
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
	discord.run_callbacks()


func save_config() -> void:
	config_file.set_value("config", "damage_visuals", damage_visuals)
	config_file.set_value("config", "instant_death_button", instant_death_button)
	config_file.set_value("config", "joystick_sensitivity", joystick_sensitivity)
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
