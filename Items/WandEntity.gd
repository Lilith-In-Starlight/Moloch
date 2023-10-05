extends RigidBody2D


var wand :Wand
var Player : KinematicBody2D

func _ready():
	add_to_group("Persistent")
	$Sprite.render_wand(wand)
	Player = get_tree().get_nodes_in_group("Player")[0]

func _process(_delta):
	$Sprite.render_wand(wand)
	$Sprite.rotation = -rotation
	$ButtonsToPress.rotation = -rotation
	
	if Player.position.distance_to(position) < 50:
		if Input.is_action_just_pressed("pickup_item"):
			if Items.append_player_wand(wand):
				if not Items.get_children().has(wand):
					if not wand.is_connected("casting_spell", get_tree().get_nodes_in_group("GameNode")[0], "_on_casting_spell"):
						var err = wand.connect("casting_spell", get_tree().get_nodes_in_group("GameNode")[0], "_on_casting_spell")
					Items.add_child(wand)
				queue_free()


func _on_exit() -> void:
	var data := {}
	data["wand"] = wand.get_json()
	data["position"] = position
	data["velocity"] = linear_velocity
	data["angular_velocity"] = angular_velocity
	data["type"] = "wanditem"
	Items.saved_entity_data.append(data)

func set_data(data):
	position = data["position"]
	linear_velocity = data["velocity"]
	angular_velocity = data["angular_velocity"]
	wand = Wand.new()
	var json = JSON.parse(data["wand"])
	wand.set_from_dict(json.result)
	Items.add_child(wand)
	
