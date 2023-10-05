extends EntityProperties

class_name CitizenProperties


var items := {}
var cloth_scraps := 3
var current_wand := 0

func _ready() -> void:
	add_to_group("Persistent")
	health.add_blood()
	health.add_body()
	health.add_soul()
	health.add_temperature()
	add_child(health)
	var wand = Wand.new()
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


func _on_exit() -> void:
	var data := {}
	data["type"] = "citizen"
	data["health"] = health.get_as_dict()
	data["cloth_scraps"] = cloth_scraps
	data["wand"] = wands[0].get_json()
	data["position"] = get_parent().position
	data["velocity"] = get_parent().speed
	Items.saved_entity_data.append(data)


func set_data(data: Directory):
	get_parent().position = get_parent().prepare_for_setup["position"]
	get_parent().speed = get_parent().prepare_for_setup["velocity"]
	var json := JSON.parse(get_parent().prepare_for_setup["wand"])
	wands[0].set_from_dict(json.result)
	cloth_scraps = get_parent().prepare_for_setup["cloth_scraps"]
	health.set_from_dict(get_parent().prepare_for_setup["health"])
