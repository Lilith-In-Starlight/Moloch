extends Node

signal achievement_unlocked(achievement)

var config_file:ConfigFile = ConfigFile.new()

# Controller Support
var last_input_was_controller := false

# Accessibility
var damage_visuals := false
var instant_death_button := false
var joystick_sensitivity := 6

# Achievements
var achievements := {
	"fun1":false,
	"fun2":false,
}


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
		
		achievements = config_file.get_value("achievements", "achievements", achievements)
		config_file.save("user://config.moloch")
	else:
		save_config()
	
	if Input.get_connected_joypads().size() > 0:
		last_input_was_controller = true


func save_config() -> void:
	config_file.set_value("config", "damage_visuals", damage_visuals)
	config_file.set_value("config", "instant_death_button", instant_death_button)
	config_file.set_value("config", "joystick_sensitivity", joystick_sensitivity)
	for i in InputMap.get_actions():
		config_file.set_value("config", "keybinds_%s"%i, InputMap.get_action_list(i))
	
	config_file.set_value("achievements", "achievements", achievements)
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
