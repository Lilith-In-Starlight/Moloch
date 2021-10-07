extends Node


var config_file:ConfigFile = ConfigFile.new()

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


func save_config() -> void:
	config_file.set_value("config", "damage_visuals", damage_visuals)
	config_file.set_value("config", "instant_death_button", instant_death_button)
	config_file.save("user://config.moloch")
