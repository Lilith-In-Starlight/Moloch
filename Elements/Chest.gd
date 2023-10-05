extends RigidBody2D

enum TYPES {
	ITEM,
	WAND,
	SPELL,
}

var type :int = TYPES.ITEM

var open := false
var Player :KinematicBody2D
var Map :Node2D

var id: int


var item :Item
var wand :Wand
var spell

func _ready():
	add_to_group("Persistent")
	item = Items.pick_random_item()
	wand = Wand.new()
	wand.fill_with_random_spells()
	spell = Items.pick_random_spell()
	Player = get_tree().get_nodes_in_group("Player")[0]
	Map = get_tree().get_nodes_in_group("World")[0]
	type = Items.LootRNG.randi()%TYPES.size()
	if Items.LootRNG.randf() < 0.4:
		spell = Items.pick_random_modifier()
	match type:
		TYPES.ITEM:
			wand.queue_free()
			wand = null
			$Sprite.modulate = "#96ff9a"
		TYPES.WAND:
			$Sprite.modulate = "#ff4da9"
		TYPES.SPELL:
			wand.queue_free()
			wand = null
			$Sprite.modulate = "#188add"


func _process(_delta):
	if not open:
		if Player.position.distance_to(position) < 26:
			if Input.is_action_just_pressed("interact_world"):
				open = true
				$Sprite.play("open")
				match type:
					TYPES.ITEM:
						var temporary_rng = RandomNumberGenerator.new()
						temporary_rng.seed = hash(Items.items_picked_in_run) + Items.LootRNG.seed
						while item.unique and item.name in Items.items_picked_in_run:
							item = Items.pick_random_item(temporary_rng)
						if not item.name in Items.items_picked_in_run:
							Items.items_picked_in_run.append(item.name)
						Map.summon_item(item, position, Vector2(-120 + randf()*240, -100))
					TYPES.WAND:
						Items.add_child(wand)
						Map.summon_wand(wand, position, Vector2(-120 + randf()*240, -100))
					TYPES.SPELL:
						Map.summon_spell(spell, position, Vector2(-120 + randf()*240, -100))

func _exit_tree() -> void:
	if wand != null and not wand.is_inside_tree():
		wand.queue_free()


func update_with_id() -> void:
	var chest_data :Dictionary = Items.saved_chest_data[id]
	if chest_data["opened"]:
		$Sprite.play("open")
		open = true
	position = chest_data["position"]
	rotation = chest_data["rotation"]
	linear_velocity = chest_data["linear_velocity"]
	angular_velocity = chest_data["angular_velocity"]


func get_chest_data() -> Dictionary:
	var data := {}
	data["opened"] = open
	data["position"] = position
	data["rotation"] = rotation
	data["linear_velocity"] = linear_velocity
	data["angular_velocity"] = angular_velocity
	return data


func _on_exit():
	Items.saved_chest_data[id] = get_chest_data()
