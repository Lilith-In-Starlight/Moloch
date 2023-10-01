extends EntityProperties


class_name FiremanProperties


func _ready() -> void:
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
	health.connect("died", get_parent(), "_on_died")
	add_child(health)
