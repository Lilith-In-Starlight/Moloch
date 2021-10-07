extends Node


var config_file:ConfigFile = ConfigFile.new()

# Accessibility
var damage_visuals := false


func _ready() -> void:
	var err := config_file.load("user://config.moloch")
	print(err)
	if err == OK:
		damage_visuals = config_file.get_value("config", "damage_visuals", false)
	else:
		save_config()


func save_config() -> void:
	config_file.set_value("config", "damage_visuals", damage_visuals)
	config_file.save("user://config.moloch")
