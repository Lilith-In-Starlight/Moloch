extends Node

class_name Flesh

signal died
signal was_damaged(type)
signal full_healed
signal effect_changed(effect, was_added)

enum DEATH_TYPES {
	BLED,
	HYPER,
	HYPO,
	SOUL,
	HOLES,
	SLICED,
	ALIVE,
}


var body_module :FleshBody = null
var blood_module :FleshBlood = null
var soul_module :FleshSoul = null
var temperature_module :FleshTemperature = null

var last_damaged_by_side_effect := false
var last_damaged_by :Node2D = null

var dead := false
var cause_of_death :int = DEATH_TYPES.ALIVE

var guarantees := 0
var chances := 0

var effects := {}


func poke_hole(amt := 1, from: Node2D = null, is_side_effect := false):
	if not body_module or amt <= 0:
		return
	
	body_module.poke_holes(amt)
	
	set_last_hurter(from, is_side_effect)


func shatter_soul(amt: float, from: Node2D = null, is_side_effect := false):
	if not soul_module or amt <= 0:
		return
	
	soul_module.change_soul(-amt)
	
	set_last_hurter(from, is_side_effect)
	

func temp_change(deg :float, from: Node2D = null, is_side_effect := false) -> void:
	if not temperature_module:
		return
	
	temperature_module.temp_change(deg)
	if deg > 0:
		emit_signal("was_damaged", "heat")
	elif deg < 0:
		emit_signal("was_damaged", "cold")
	
	set_last_hurter(from, is_side_effect)


func slice(from: Node2D = null, is_side_effect := false):
	if not body_module:
		return
	
	body_module.slice()


func add_effect(effect: String) -> void:	
	if not effect in effects:
		effects[effect] = get_effect_node(effect)	
		add_child(effects[effect])
		emit_signal("effect_changed", effect, true)
	else:
		effects[effect].duration += randf() * 6.0


func remove_effect(effect: String) -> void:
	effects.erase(effect)
	emit_signal("effect_changed", effect, false)


func get_effect_node(effect: String) -> StatusEffect:
	match effect:
		"onfire":
			return OnFire.new()
		"confused":
			return Confused.new()
		_: return null


func full_heal():
	if body_module:
		body_module.full_heal()
	if soul_module:
		soul_module.full_heal()
	if blood_module:
		blood_module.full_heal()
	if temperature_module:
		temperature_module.full_heal()


func self_terminate():
	dead = true
	emit_signal("died")


func set_last_hurter(from: Node2D, is_side_effect: bool) -> void:
	if dead: return
	
	last_damaged_by_side_effect = is_side_effect
	last_damaged_by = from if is_instance_valid(from) else null


func attempt_death():
	if (guarantees == 0 and chances == 0) or (chances > 0 and randi()%3 > 0):
		dead = true
		emit_signal("died")
	else:
		if guarantees > 0: guarantees -= 1
		elif chances > 0: chances -= 1
		
		cause_of_death = DEATH_TYPES.ALIVE
		full_heal()


func _on_poked_hole(amt: int):
	emit_signal("was_damaged", "hole")




func _on_ran_out_of_blood():
	if not blood_module.is_vital:
		return
		
	if cause_of_death == DEATH_TYPES.ALIVE:
		cause_of_death = DEATH_TYPES.BLED
	
	attempt_death()


func _on_sliced():
	if not body_module.is_vital:
		return
	
	if cause_of_death == DEATH_TYPES.ALIVE:
		cause_of_death = DEATH_TYPES.SLICED
	
	attempt_death()


func _on_max_holed():
	if not body_module.is_vital:
		return
		
	if cause_of_death == DEATH_TYPES.ALIVE:
		cause_of_death = DEATH_TYPES.HOLES
	
	attempt_death()


func _on_ran_out_of_soul():
	if not soul_module.is_vital:
		return
		
	if cause_of_death == DEATH_TYPES.ALIVE:
		cause_of_death = DEATH_TYPES.SOUL
	
	attempt_death()


func _on_hypothermia_died():
	if not temperature_module.is_vital:
		return
		
	if cause_of_death == DEATH_TYPES.ALIVE:
		cause_of_death = DEATH_TYPES.HYPO
	
	attempt_death()


func _on_hyperthermia_died():
	if not temperature_module.is_vital:
		return
		
	if cause_of_death == DEATH_TYPES.ALIVE:
		cause_of_death = DEATH_TYPES.HYPER
	
	attempt_death()


func add_body() -> FleshBody:
	if body_module:
		return body_module
	var new_module := FleshBody.new()
	new_module.connect("hole_poked", self, "_on_poked_hole")
	new_module.connect("max_holed", self, "_on_max_holed")
	new_module.connect("sliced", self, "_on_sliced")
	add_child(new_module)
	body_module = new_module
	return new_module


func add_soul() -> FleshSoul:
	if soul_module:
		return soul_module
	var new_module := FleshSoul.new()
	new_module.connect("ran_out_of_soul", self, "_on_ran_out_of_soul")
	add_child(new_module)
	soul_module = new_module
	return new_module


func add_blood() -> FleshBlood:
	if blood_module:
		return blood_module
	var new_module := FleshBlood.new()
	new_module.connect("ran_out_of_blood", self, "_on_ran_out_of_blood")
	add_child(new_module)
	blood_module = new_module
	return new_module


func add_temperature() -> FleshTemperature:
	if temperature_module:
		return temperature_module
	var new_module := FleshTemperature.new()
	new_module.connect("hyperthermia_died", self, "_on_hyperthermia_died")
	new_module.connect("hypothermia_died", self, "_on_hypothermia_died")
	add_child(new_module)
	temperature_module = new_module
	return new_module

func quantify_best_status() -> float:
	var value := 0.0
	if temperature_module:
		value += max(temperature_module.max_temperature, temperature_module.temperature) + abs(temperature_module.min_temperature)
	if soul_module:
		value += soul_module.amount
	if blood_module:
		value += max(blood_module.amount, blood_module.maximum)
	return value


func get_as_dict() -> Dictionary:
	var dict := {}
	if blood_module: dict["blood_module"] = blood_module.get_as_dict()
	if soul_module: dict["soul_module"] = soul_module.get_as_dict()
	if body_module: dict["body_module"] = body_module.get_as_dict()
	if temperature_module: dict["temperature_module"] = temperature_module.get_as_dict()
	
	dict["guarantees"] = guarantees
	dict["chances"] = chances
	
	return dict


func set_from_dict(dict:Dictionary):
	if "blood_module" in dict:
		if not blood_module: add_blood()
		blood_module.set_from_dict(dict["blood_module"])
		dict.erase("blood_module")
	
	if "soul_module" in dict:
		if not soul_module: add_soul()
		soul_module.set_from_dict(dict["soul_module"])
		dict.erase("soul_module")
	
	if "body_module" in dict:
		if not body_module: add_body()
		body_module.set_from_dict(dict["body_module"])
		dict.erase("body_module")
	
	if "temperature_module" in dict:
		if not temperature_module: add_temperature()
		temperature_module.set_from_dict(dict["temperature_module"])
		dict.erase("temperature_module")
	
	for key in dict:
		set(key, dict[key])
