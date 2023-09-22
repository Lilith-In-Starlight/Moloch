extends EntityProperties

class_name MalekaraiMalekhaProperties


var items := {}
var cloth_scraps := 10
var current_wand := 0


func _ready() -> void:
	var wand = Wand.new()
	wand.fill_with_random_spells()
	Items.add_child(wand)
	wands.append(wand)
	wand = Wand.new()
	wand.fill_with_random_spells()
	Items.add_child(wand)
	wands.append(wand)
	wand = Wand.new()
	wand.fill_with_random_spells()
	Items.add_child(wand)
	wands.append(wand)
	wand = Wand.new()
	wand.fill_with_random_spells()
	Items.add_child(wand)
	wands.append(wand)

func get_health() -> Flesh:
	return health

func count_items(item: String) -> int:
	if not item in items:
		return 0
	return items[item]

func get_wand() -> Wand:
	if wands.empty(): return null
	return wands[current_wand]

func set_cloth_straps(value):
	self.cloth_scraps = value

func get_cloth_straps():
	return cloth_scraps

func get_wands() -> Array:
	return wands

func is_cast_blocked() -> bool:
	if get_wand() == null: return false
	return get_wand().running
