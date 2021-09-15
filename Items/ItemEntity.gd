extends RigidBody2D


var item :Item

func _ready():
	$Sprite.texture = item.texture

func _process(delta):
	$Sprite.rotation = -rotation
	
	if Input.is_action_just_pressed("down"):
		Items.player_items.append(item.id)
		queue_free()
