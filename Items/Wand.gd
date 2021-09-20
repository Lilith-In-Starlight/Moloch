extends Reference

class_name Wand

var spell_capacity := 1 + randi()%5
var spell_recharge := randf()*0.3
var full_recharge := randf()*1.7
var spells := []

var color1 := Color(randf(), randf(), randf())
var color2 := Color(randf(), randf(), randf())
var color3 := Color(randf(), randf(), randf())

var shuffle := false

var current_spell := 0

var recharge := 0.0
var running := false


func _init():
	if randf() < 0.1:
		shuffle = true
	var randspell = Items.pick_random_spell()
	spells.append(randspell)
	
	if randi()%100 > 85 and spell_capacity > 1:
		randspell = Items.pick_random_spell()
		spells.append(randspell)
	
	while spells.size() < spell_capacity:
		spells.append(null)


func string():
	return "SC: " + str(spell_capacity) + " SR: " + str(spell_recharge) + " FR: " + str(full_recharge) + " S: " + str(spells) + " RC: " + str(recharge) + " R: " + str(running) + " CS: " + str(current_spell)

func duplicate():
	var w = get_script().new()
	w.spell_capacity = spell_capacity
	w.spell_recharge = spell_recharge
	w.full_recharge = full_recharge
	w.color1 = color1
	w.color2 = color2
	w.color3 = color3
	w.spells = spells.duplicate()
	return w
