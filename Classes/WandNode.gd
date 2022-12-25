extends Node

class_name Wand

signal finished_casting
signal casting_spell(spell, wand, caster)

const MAX_CAPACITY := 12

var spell_capacity :int = 1 + Items.LootRNG.randi()%(MAX_CAPACITY-1) setget set_spell_capacity
var cast_cooldown :float = Items.LootRNG.randf()*0.3
var recharge_cooldown :float = Items.LootRNG.randf()*0.4
var heat_resistance :float = Items.LootRNG.randf()*0.7
var soul_resistance :float = Items.LootRNG.randf()*0.7
var push_resistance :float = Items.LootRNG.randf()*0.7
var shuffle := false
var spells := []
var spell_offset := Vector2(0, 0)

var color1 := Color(Items.LootRNG.randf(), Items.LootRNG.randf(), Items.LootRNG.randf())
var color2 := Color(Items.LootRNG.randf(), Items.LootRNG.randf(), Items.LootRNG.randf())
var color3 := Color(Items.LootRNG.randf(), Items.LootRNG.randf(), Items.LootRNG.randf())

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
		if Items.LootRNG.randf() < 0.3 and not (i == 0 and spells_to_give == 1):
			spells.append(Items.pick_random_modifier())
			continue
		spells.append(Items.pick_random_spell())
	
	fix_spells()


func _ready() -> void:
	if get_tree().get_nodes_in_group("GameNode").empty():
		return
	
	connect("casting_spell", get_tree().get_nodes_in_group("GameNode")[0], "_on_casting_spell")


func string():
	return "SC: " + str(spell_capacity) + " SR: " + str(cast_cooldown) + " FR: " + str(recharge_cooldown) + " S: " + str(spells) + " RC: " + str(recharge) + " R: " + str(running) + " CS: " + str(current_spell)


func shuffle():
	if shuffle:
		spells.shuffle()


func run(caster: Node2D):
	if self.running:
		return
	
	var spell_stack = parse_spells()
	
	if spell_stack is String:
		self.running = false
		return
		
	var current_spell :int = spell_stack.size() - 1
	self.running = true
	var cast_cooldown_multiplier := 1.0
	var recharge_cooldown_multiplier := 1.0
	
	while current_spell >= 0:
		if !spell_stack[current_spell].wand_modifiers.empty():
			match spell_stack[current_spell].wand_modifiers[0]:
				"cast_cooldown": cast_cooldown_multiplier /= float(spell_stack[current_spell].wand_modifiers[1])
				"recharge_cooldown": recharge_cooldown_multiplier /= float(spell_stack[current_spell].wand_modifiers[1])
			
		emit_signal("casting_spell", spell_stack[current_spell], self, caster)
		current_spell -= 1
		
		if current_spell > 0:
			yield(get_tree().create_timer(cast_cooldown * cast_cooldown_multiplier), "timeout")
	
	yield(get_tree().create_timer(recharge_cooldown * recharge_cooldown_multiplier), "timeout")
	self.running = false
	emit_signal("finished_casting")


func parse_spells():
	var current_parse := spells.size() - 1
	var spell_stack := []
	while current_parse >= 0:
		var current_spell = spells[current_parse]
		
		if current_spell.is_wand_mod: # It's a wand modifier
			if spell_stack.empty():
				current_parse -= 1
				continue
			var wand_mod = get_wand_mod_property(current_spell)
			var top_spell = spell_stack.pop_back()
			top_spell = top_spell.duplicate()
			top_spell.wand_modifiers = wand_mod
			spell_stack.append(top_spell)
			current_parse -= 1
			continue
		
		if current_spell.is_behavior_mod: # It's a behavior modifier
			if spell_stack.empty():
				current_parse -= 1
				continue
			var top_spell = spell_stack.pop_back()
			top_spell = top_spell.duplicate()
			top_spell.behavior_modifiers.append(current_spell.id)
			spell_stack.append(top_spell)
			current_parse -= 1
			continue
		
		if !current_spell.is_cast_mod: # It's not a modifier
			spell_stack.append(current_spell)
			current_parse -= 1
			continue
		
		if spell_stack.size() < current_spell.inputs: # It's a modifier but its inputs cannot be filled
			return "Couldn't parse cast"
		
		# It's a modifier and its inputs can be filled
		var modified_spell = current_spell.duplicate()
		for i in modified_spell.inputs:
			var top_spell = spell_stack.pop_back()
			top_spell = top_spell.duplicate()
			top_spell.behavior_modifiers.append_array(modified_spell.behavior_modifiers)
			modified_spell.input_contents.append(top_spell)
		
		spell_stack.append(modified_spell)
		current_parse -= 1
	
	return spell_stack


func unrun():
	if running:
		running = false
		spell_offset = Vector2(0, 0)
		emit_signal("finished_casting")


func fix_spells() -> void:
#	while spells.size() < spell_capacity:
#		spells.append(null)
	while spells.size() > spell_capacity:
		spells.pop_back()


func set_spell_capacity(new_value:int) -> void:
	spell_capacity = new_value
	fix_spells()


func get_json() -> String:
	var string := "{"
	string += '"cast":' + '"' + str(cast_cooldown) + '",'
	string += '"recharge":' + '"' + str(recharge_cooldown) + '",'
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


func get_wand_mod_property(spell):
	match spell.id:
		"fast_cast": return ["cast_cooldown", spell.level]
		"fast_recharge": return ["recharge_cooldown", spell.level]
		"slow_cast": return ["cast_cooldown", 1/float(spell.level)]
		"slow_recharge": return ["recharge_cooldown", 1/float(spell.level)]
