extends EntityProperties

class_name PlayerProperties


var items = Items.player_items # passed by reference
var cloth_scraps = Items.cloth_scraps setget set_cloth_straps, get_cloth_straps


func _ready() -> void:
	Items.player_hitbox = $"../CollisionShape2D".shape


func get_health() -> Flesh:
	return Items.player_health


func count_items(item: String) -> int:
	return Items.count_player_items(item)

func get_wand() -> Wand:
	return Items.get_player_wand()

func set_cloth_straps(value):
	Items.cloth_scraps = value

func get_cloth_straps():
	return Items.cloth_scraps

func get_wands() -> Array:
	return Items.player_wands

func is_cast_blocked() -> bool:
	return get_tree().get_nodes_in_group("HUD")[0].block_cast
