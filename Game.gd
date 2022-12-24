extends Node2D


func _ready() -> void:
	for i in Items.player_wands:
		i.connect("casting_spell", self, "_on_casting_spell")


func _on_casting_spell(spell: Spell, wand: Wand):
	if !spell.is_cast_mod:
		print(spell.name)
		# TODO: Make this cast the spell
		return
	
	match spell.name:
		"multiply":
			for i in spell.level:
				_on_casting_spell(spell.input_contents[0], wand)
		"unify":
			_on_casting_spell(spell.input_contents[0], wand)
			_on_casting_spell(spell.input_contents[1], wand)


