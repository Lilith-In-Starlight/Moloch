extends Object

class_name Wand

var spell_capacity := 1 + randi()%5
var spell_recharge := randf()*0.3
var full_recharge := randf()*1.7
var spells := []

var current_spell := 0

var recharge := 0.0
var running := false

func _init():
	spells.append(Items.spells[randi()%Items.spells.size()])
	if randi()%100 > 85 and spell_capacity > 1:
		spells.append(Items.spells[randi()%Items.spells.size()])


func string():
	return "SC: " + str(spell_capacity) + " SR: " + str(spell_recharge) + " FR: " + str(full_recharge) + " S: " + str(spells) + " RC: " + str(recharge) + " R: " + str(running) + " CS: " + str(current_spell)
