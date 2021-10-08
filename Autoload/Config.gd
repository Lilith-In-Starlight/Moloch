extends Node


var config_file:ConfigFile = ConfigFile.new()

# Controller Support
var last_input_was_controller := false

# Accessibility
var damage_visuals := false
var instant_death_button := false


func _ready() -> void:
	var err := config_file.load("user://config.moloch")
	if err == OK:
		damage_visuals = config_file.get_value("config", "damage_visuals", false)
		instant_death_button = config_file.get_value("config", "instant_death_button", false)
	else:
		save_config()
	
	if Input.get_connected_joypads().size() > 0:
		last_input_was_controller = true


func save_config() -> void:
	config_file.set_value("config", "damage_visuals", damage_visuals)
	config_file.set_value("config", "instant_death_button", instant_death_button)
	config_file.save("user://config.moloch")


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		last_input_was_controller = false
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		last_input_was_controller = true
