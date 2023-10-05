extends EntityProperties


class_name FiremanProperties


func _ready() -> void:
	add_to_group("Persistent")
	var new_wand := Wand.new()
	var base_mod :Spell = Items.base_spell_mods["ghost"]
	new_wand.cast_cooldown = 0.1
	new_wand.spells.append(base_mod)
	new_wand.spells.append(Items.spells[1]["fireball"])
	Items.add_child(new_wand)
	wands.append(new_wand)
	
	new_wand = Wand.new()
	new_wand.cast_cooldown = 0.1
	new_wand.spells.append(base_mod)
	new_wand.spells.append(Items.spells[1]["fireball"])
	Items.add_child(new_wand)
	wands.append(new_wand)
	
	health.add_body()
	health.add_temperature()
	health.add_soul()
	health.body_module.max_holes = 24
	health.soul_module.maximum = 2.0
	health.soul_module.amount = 2.0
	health.temperature_module.max_temperature = 244
	health.temperature_module.min_temperature = 10
	health.temperature_module.temperature = 60
	health.connect("died", get_parent(), "_on_died")
	add_child(health)


func _on_exit() -> void:
	var data := {}
	data["type"] = "fireman"
	data["health"] = health.get_as_dict()
	data["wand1"] = wands[0].get_json()
	data["wand2"] = wands[1].get_json()
	data["position"] = get_parent().position
	data["velocity"] = get_parent().velocity
	data["angle"] = get_parent().angle
	Items.saved_entity_data.append(data)


func set_data(data: Directory):
	get_parent().position = get_parent().prepare_for_setup["position"]
	get_parent().velocity = get_parent().prepare_for_setup["velocity"]
	get_parent().angle = get_parent().prepare_for_setup["angle"]
	var json := JSON.parse(get_parent().prepare_for_setup["wand1"])
	wands[0].set_from_dict(json.result)
	json = JSON.parse(get_parent().prepare_for_setup["wand2"])
	wands[1].set_from_dict(json.result)
	health.set_from_dict(get_parent().prepare_for_setup["health"])
