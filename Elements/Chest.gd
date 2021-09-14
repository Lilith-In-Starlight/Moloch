extends RigidBody2D

enum TYPES {
	ITEM,
	WAND,
}

var type :int = TYPES.ITEM

var contents := ""
var open := false
var Player :KinematicBody2D

func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]
	type = randi()%TYPES.size()
	match type:
		TYPES.ITEM:
			contents = Items.items[randi()%Items.items.size()]
			$Polygon.color = "#96ff9a"
		TYPES.WAND:
			$Polygon.color = "#ff4da9"

func _process(delta):
	if not open:
		if Player.position.distance_to(position) < 16:
			if Input.is_action_just_pressed("down"):
				open = true
				match type:
					TYPES.ITEM:
						Items.player_items.append(contents)
					TYPES.WAND:
						for i in Items.player_wands.size():
							if Items.player_wands[i] == null:
								Items.player_wands[i] = Wand.new()
								break
