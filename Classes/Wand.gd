extends Reference

class_name Wand

signal finished_casting

const MAX_CAPACITY := 12

var spell_capacity :int = 1 + Items.LootRNG.randi()%(MAX_CAPACITY-1) setget set_spell_capacity
var spell_recharge :float = Items.LootRNG.randf()*0.3
var full_recharge :float = Items.LootRNG.randf()*0.4
var heat_resistance :float = Items.LootRNG.randf()*0.7
var soul_resistance :float = Items.LootRNG.randf()*0.7
var push_resistance :float = Items.LootRNG.randf()*0.7
var spells := []
var spell_offset := Vector2(0, 0)

var color1 := Color(Items.LootRNG.randf(), Items.LootRNG.randf(), Items.LootRNG.randf())
var color2 := Color(Items.LootRNG.randf(), Items.LootRNG.randf(), Items.LootRNG.randf())
var color3 := Color(Items.LootRNG.randf(), Items.LootRNG.randf(), Items.LootRNG.randf())

var shuffle := false

var current_spell := 0

var recharge := 0.0
var running := false
var can_cast := true


func _init():
	if Items.LootRNG.randf() < 0.15:
		shuffle = true
	
	# Basically, you want an amount of spells that is most likely to be 2
	# randfn can return negatives, you dont want that
	# you round it, you only want integers
	# you dont want the amount of spells to be larger than the spell capacity
	# you dont want it to be zero, that's only for the starting wand
	var spells_to_give := clamp(min(spell_capacity, round(abs(Items.LootRNG.randfn(2.0, 3.0)))), 1, 12)
	for i in spells_to_give:
		if randf() < 0.3 and not (i == 0 and spells_to_give == 1):
			spells.append(Items.pick_random_modifier())
			continue
		spells.append(Items.pick_random_spell())
	
	fix_spells()

func string():
	return "SC: " + str(spell_capacity) + " SR: " + str(spell_recharge) + " FR: " + str(full_recharge) + " S: " + str(spells) + " RC: " + str(recharge) + " R: " + str(running) + " CS: " + str(current_spell)


func duplicate():
	var w = get_script().new()
	w.spell_capacity = spell_capacity
	w.spell_recharge = spell_recharge
	w.full_recharge = full_recharge
	w.heat_resistance = heat_resistance
	w.soul_resistance = soul_resistance
	w.push_resistance = push_resistance
	w.color1 = color1
	w.color2 = color2
	w.color3 = color3
	w.spells = spells.duplicate()
	return w


func shuffle():
	if shuffle:
		spells.shuffle()
		for s in spells.size():
			if spells[s] == null:
				for s2 in range(s, spells.size()):
					if spells[s2] != null:
						spells[s] = spells[s2]
						spells[s2] = null
						break


func run(Caster:Node2D):
	if not self.running:
		spell_offset = Vector2(0, 0)
		can_cast = true
		self.running = true
		var speed_mult := 1.0
		var last := 0
		var count := true
		for i in spells:
			if i is SpellMod:
				if i.id == "fasterw":
					speed_mult /= float(i.level)
			if i == null:
				count = false
			if count:
				last += 1
		Items.running_wands.append([self, Caster, spell_recharge, full_recharge * speed_mult, last])


func unrun():
	if running:
		running = false
		spell_offset = Vector2(0, 0)
		emit_signal("finished_casting")


func fix_spells() -> void:
	while spells.size() < spell_capacity:
		spells.append(null)
	while spells.size() > spell_capacity:
		spells.pop_back()


func set_spell_capacity(new_value:int) -> void:
	spell_capacity = new_value
	fix_spells()


func get_json() -> String:
	var string := "{"
	string += '"cast":' + '"' + str(spell_recharge) + '",'
	string += '"recharge":' + '"' + str(full_recharge) + '",'
	string += '"spellcap":' + '"' + str(spell_capacity) + '",'
	string += '"heat":' + '"' + str(heat_resistance) + '",'
	string += '"soul":' + '"' + str(soul_resistance) + '",'
	string += '"push":' + '"' + str(push_resistance) + '",'
	if shuffle:
		string += '"shuffle":"1",'
	else:
		string += '"shuffle":"0",'
	string += '"color1":"#' + color1.to_html() + '",'
	string += '"color2":"#' + color2.to_html() + '",'
	string += '"color3":"#' + color3.to_html() + '"}'
	return string

