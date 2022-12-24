extends Node2D


func _ready() -> void:
	for i in Items.player_wands:
		i.connect("casting_spell", self, "_on_casting_spell")


func _on_casting_spell(spell: Spell, wand: Wand, caster: Node2D):
	if !spell.is_cast_mod:
		var spell_instance = spell.entity.instance()
		spell_instance.CastInfo.Caster = caster
		spell_instance.CastInfo.goal = caster.looking_at()
		spell_instance.CastInfo.wand = wand
		add_child(spell_instance)
	
	match spell.id:
		"multiply":
			for i in spell.level:
				_on_casting_spell(spell.input_contents[0], wand, caster)
		"unify":
			_on_casting_spell(spell.input_contents[0], wand, caster)
			_on_casting_spell(spell.input_contents[1], wand, caster)


