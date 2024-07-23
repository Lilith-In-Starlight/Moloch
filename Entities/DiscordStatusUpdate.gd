extends Node

var health :Flesh
var temp_stage: int = 0
var detail := ""

func _process(delta: float) -> void:
	if Config.discord != null and health != null:
		temp_stage = get_parent().temp_stage
		detail = ""
		if health.blood_module and health.body_module.holes > 0:
			detail += "Bleeding, "
		if health.body_module:
			if health.body_module.broken_legs == 1:
				detail += "Broken leg, "
			elif health.body_module.broken_legs == 2:
				detail += "Broken legs, "
		else:
			detail += "Bodyless, "
		if health.temperature_module:
			if health.temperature_module.temp_state == 1:
				detail += "Too hot, "
			elif health.temperature_module.temp_state == 2:
				detail += "Heat stroke, "
			elif health.temperature_module.temp_state == -1:
				detail += "Too cold, "
			elif health.temperature_module.temp_state == -2:
				detail += "Hypothermia, "
		else:
			detail += "Temperatureless, "
		if health.soul_module:
			if health.soul_module.amount > health.soul_module.maximum:
				detail += "Soulful, "
			elif health.soul_module.amount < 0.8:
				detail += "Lacking in Soul, "
			elif health.soul_module.amount < 0.4:
				detail += "Soulless, "
		else:
			detail += "Non-existant, "
		if health.blood_module and health.blood_module.is_vital:
			if health.blood_module.substance == "nitroglycerine":
				detail += "Volatile, "
			elif health.blood_module.substance == "water":
				detail += "Water Blood, "
		else:
			detail += "Bloodless, "
		if health.effects.has("onfire"):
			detail += "On fire, "
		detail = detail.rstrip(", ")
		if detail == "":
			detail = "All seems fine"
		if health.dead:
			detail = "Dead"
		if Config.discord != null:
			var act = Discord.Activity.new()
			act.state = "Level %s, %s" % [str(Items.level), str(Items.using_seed)]
			act.details = detail
			act.assets.large_image = "logoimage"
			act.assets.large_text = "Optimizing for X"
			act.timestamps.start = Config.app_start_time
			Config.discord.get_activity_manager().update_activity(act)
