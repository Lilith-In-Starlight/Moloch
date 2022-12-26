extends Node2D


func _ready() -> void:
	for i in Items.player_wands:
		i.connect("casting_spell", self, "_on_casting_spell")


func _on_casting_spell(spell: Spell, wand: Wand, caster: Node2D, offset: float = 0.0):
	if !spell.is_cast_mod:
		var spell_instance = spell.entity.instance()
		spell_instance.CastInfo.Caster = caster
		spell_instance.CastInfo.goal_offset = Vector2(-offset + randf()*offset*2, -offset + randf()*offset*2) * 50
		spell_instance.CastInfo.goal = caster.looking_at()
		spell_instance.CastInfo.wand = wand
		spell_instance.CastInfo.modifiers = spell.behavior_modifiers
		spell_instance.CastInfo.spell = spell
		add_child(spell_instance)
		
		return
	
	for i in spell.input_contents:
		i.behavior_modifiers.append_array(spell.behavior_modifiers.duplicate())
		var counts := {}
		for j in i.behavior_modifiers:
			if counts.has(j):
				counts[j] += 1
			else:
				counts[j] = 1
			if counts[j] == 2:
				counts[j] = 0
				i.behavior_modifiers.erase(j)
				i.behavior_modifiers.erase(j)
	match spell.id:
		"multiply":
			_on_casting_spell(spell.input_contents[0], wand, caster, 0)
			for i in spell.level - 1:
				_on_casting_spell(spell.input_contents[0], wand, caster, offset - 2 + randf()*2)
		"unify":
			_on_casting_spell(spell.input_contents[0], wand, caster)
			_on_casting_spell(spell.input_contents[1], wand, caster)


func _process(delta: float) -> void:
	if Items.selected_wand >= Items.player_wands.size():
		Items.selected_wand = Items.player_wands.size() - 1
	if not Items.player_wands.empty() and Items.selected_wand < 0:
		Items.selected_wand = 0
