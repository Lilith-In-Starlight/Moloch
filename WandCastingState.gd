extends Reference


class_name WandCastingInfo


var spell: Spell
var wand
var offset: float
var caster: Node
var position_caster: Node


func duplicate():
	var new = get_script().new()
	new.spell = spell
	new.wand = wand
	new.offset = offset
	new.caster = caster
	new.position_caster = position_caster
	return new
