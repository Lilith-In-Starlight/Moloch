extends Reference

class_name Wand

var spell_capacity := 1 + randi()%5
var spell_recharge := randf()*0.3
var full_recharge := randf()*1.7
var spells := []

var current_spell := 0

var recharge := 0.0
var running := false


func _init():
	var randspell = Items.spells[randi()%Items.spells.size()]
	while randspell == "fuck you" and randf()<0.98:
		randspell = Items.spells[randi()%Items.spells.size()]
	spells.append(randspell)
	if randi()%100 > 85 and spell_capacity > 1:
		randspell = Items.spells[randi()%Items.spells.size()]
		while randspell == "fuck you" and randf()<0.98:
			randspell = Items.spells[randi()%Items.spells.size()]
		spells.append(randspell)


func string():
	return "SC: " + str(spell_capacity) + " SR: " + str(spell_recharge) + " FR: " + str(full_recharge) + " S: " + str(spells) + " RC: " + str(recharge) + " R: " + str(running) + " CS: " + str(current_spell)
