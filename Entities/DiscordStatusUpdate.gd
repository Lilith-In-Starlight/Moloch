extends Node


onready var health :Flesh = get_parent().health_object()
var temp_stage: int = 0
var detail := ""


func _process(delta: float) -> void:
	if Config.discord != null:
		temp_stage = get_parent().temp_stage
		detail = ""
		if health.needs_blood and health.poked_holes > 0:
			detail += "Bleeding, "
		if health.broken_moving_appendages == 1:
			detail += "Broken leg, "
		elif health.broken_moving_appendages == 2:
			detail += "Broken legs, "
		if temp_stage == 1:
			detail += "Too hot, "
		elif temp_stage == 2:
			detail += "Heat stroke, "
		elif temp_stage == -1:
			detail += "Too cold, "
		elif temp_stage == -2:
			detail += "Hypothermia, "
		if health.soul > health.needed_soul:
			detail += "Soulful, "
		elif health.soul < 0.43:
			detail += "Soulless, "
		if health.blood_substance == "nitroglycerine":
			detail += "Volatile, "
		elif health.blood_substance == "water":
			detail += "Water Blood, "
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
