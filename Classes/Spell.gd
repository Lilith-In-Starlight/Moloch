extends Reference

class_name Spell

var name :String
var id :String
var description :String
var texture: Texture
var entity :PackedScene
var tier :int

# Cast mods only
var is_cast_mod: bool = false
var behavior_mods: Array = []
var minimum_level: int = 0
var maximum_level: int = 0
var level: int = 0

var inputs: int = 0
var input_contents: Array = []


func duplicate():
	var new = get_script().new()
	new.name = name
	new.id = id
	new.description = description
	new.texture = texture
	new.entity = entity
	new.tier = tier
	
	new.is_cast_mod = is_cast_mod
	new.behavior_mods = behavior_mods
	new.minimum_level = minimum_level
	new.maximum_level = maximum_level
	new.level = level
	
	new.inputs = inputs
	new.input_contents = input_contents
	
	return new
