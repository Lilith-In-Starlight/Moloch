extends RigidBody2D


var item :Item
var Player : KinematicBody2D

func _ready():
	add_to_group("Persistent")
	$Sprite.texture = item.texture
	Player = get_tree().get_nodes_in_group("Player")[0]

func _process(_delta):
	$Sprite.rotation = -rotation
	$ButtonsToPress.rotation = -rotation
	
	if Player.position.distance_to(position) < 50:
		if Input.is_action_just_pressed("pickup_item"):
			Items.add_item(item.id)
			Items.last_pickup = item
			queue_free()


func _on_exit() -> void:
	var data := {}
	data["item"] = item.id
	data["position"] = position
	data["velocity"] = linear_velocity
	data["angular_velocity"] = angular_velocity
	data["type"] = "itemitem"
	Items.saved_entity_data.append(data)

func set_data(data):
	position = data["position"]
	linear_velocity = data["velocity"]
	angular_velocity = data["angular_velocity"]
	item = Items.all_items[data["item"]]
