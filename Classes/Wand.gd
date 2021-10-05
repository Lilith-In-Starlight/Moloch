extends Reference

class_name Wand

signal finished_casting

var spell_capacity :int = 1 + Items.LootRNG.randi()%5 setget set_spell_capacity
var spell_recharge :float = Items.LootRNG.randf()*0.3
var full_recharge :float = Items.LootRNG.randf()*1.7
var spells := []

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
	var randspell = Items.pick_random_spell()
	spells.append(randspell)
	
	if Items.LootRNG.randi()%100 > 85 and spell_capacity > 1:
		randspell = Items.pick_random_spell()
		spells.append(randspell)
	
	fix_spells()

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
		can_cast = true
		self.running = true
		Items.running_wands.append([self, Caster])


func unrun():
	if running:
		running = false
		emit_signal("finished_casting")


func fix_spells() -> void:
	while spells.size() < spell_capacity:
		spells.append(null)
	while spells.size() > spell_capacity:
		spells.pop_back()


func set_spell_capacity(new_value:int) -> void:
	spell_capacity = new_value
	fix_spells()
