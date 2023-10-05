extends RigidBody2D


var spell :Spell
var Player : KinematicBody2D

func _ready():
	add_to_group("Persistent")
	$Sprite.texture = spell.texture
	Player = get_tree().get_nodes_in_group("Player")[0]

func _process(_delta):
	$Sprite.rotation = -rotation
	$ButtonsToPress.rotation = -rotation
	$Sprite.texture = spell.texture
	if Player.position.distance_to(position) < 50:
		if Input.is_action_just_pressed("pickup_item"):
			if Items.player_spells.size() < 6:
				Items.player_spells.append(spell)
				queue_free()


func _on_exit() -> void:
	var data := {}
	data["type"] = "spellitem"	
	if spell.is_modifier():
		data["spell"] = spell.id
		data["mod"] = true
		data["level"] = spell.level
		data["desc"] = spell.description
	else:
		data["mod"] = false
		data["type"] = "spellitem"	
		data["spell"] = spell.id
	data["position"] = position
	data["velocity"] = linear_velocity
	data["angular_velocity"] = angular_velocity
	Items.saved_entity_data.append(data)


func set_data(data):
	position = data["position"]
	linear_velocity = data["velocity"]
	angular_velocity = data["angular_velocity"]
	if not data["mod"]:
		spell = Items.all_spells[data["spell"]]
	elif data["mod"]:
		spell = Items.base_spell_mods[data["spell"]].duplicate()
		spell.level = data["level"]
		spell.description = data["desc"]
