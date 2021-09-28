extends RigidBody2D

enum TYPES {
	ITEM,
	WAND,
	SPELL,
}

var type :int = TYPES.ITEM

var open := false
var Player :KinematicBody2D

func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]
	type = Items.LootRNG.randi()%TYPES.size()
	match type:
		TYPES.ITEM:
			$Sprite.modulate = "#96ff9a"
		TYPES.WAND:
			$Sprite.modulate = "#ff4da9"
		TYPES.SPELL:
			$Sprite.modulate = "#188add"

func _process(delta):
	if not open:
		if Player.position.distance_to(position) < 16:
			if Input.is_action_just_pressed("down"):
				open = true
				$Sprite.play("open")
				match type:
					TYPES.ITEM:
						var new := preload("res://Items/ItemEntity.tscn").instance()
						new.item = Items.pick_random_item()
						get_parent().add_child(new)
						new.position = position
						new.linear_velocity.x = -120 + randf()*240
					TYPES.WAND:
						var new := preload("res://Items/WandEntity.tscn").instance()
						new.wand = Wand.new()
						get_parent().add_child(new)
						new.position = position
						new.linear_velocity.x = -120 + randf()*240
					TYPES.SPELL:
						var new := preload("res://Items/SpellEntity.tscn").instance()
						new.spell = Items.pick_random_spell()
						if Items.LootRNG.randf() < 0.18:
							new.spell = Items.pick_random_modifier()
						get_parent().add_child(new)
						new.position = position
						new.linear_velocity.x = -120 + randf()*240
