extends Reference

class_name Spell

var name :String
var id :String
var description :String
var texture: Texture
var entity :PackedScene
var tier :int
var behavior_modifiers: Array = []

# Cast mods only
var is_cast_mod: bool = false
var is_behavior_mod: bool = false
var minimum_level: int = 0
var maximum_level: int = 0
var level: int = 0

var inputs: int = 0
var input_contents: Array = []

var is_wand_mod: bool = false
var wand_modifiers: Array = []

var iters := 0

var soul_cost := false
var temp_cost := 0
var blood_cost := false


func is_modifier():
	return is_wand_mod or is_behavior_mod or is_cast_mod


func duplicate():
	var new = get_script().new()
	new.name = name
	new.id = id
	new.description = description
	new.texture = texture
	new.entity = entity
	new.tier = tier
	new.behavior_modifiers = behavior_modifiers.duplicate()
	
	new.is_cast_mod = is_cast_mod
	new.is_behavior_mod = is_behavior_mod
	new.minimum_level = minimum_level
	new.maximum_level = maximum_level
	new.level = level
	
	new.inputs = inputs
	new.input_contents = input_contents.duplicate()
	
	new.is_wand_mod = is_wand_mod
	new.wand_modifiers = wand_modifiers.duplicate()
	
	return new
