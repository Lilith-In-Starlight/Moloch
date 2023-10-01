extends EntityController


onready var player :PlayerCharacter = get_tree().get_nodes_in_group("Player")[0]
onready var parent :Node2D = get_parent()
var player_detector: RayCast2D

var last_known_position := Vector2()


func _ready() -> void:
	last_known_position = parent.position + Vector2(-1 + randf() * 2, -1 + randf() * 2) * 100

func _physics_process(delta: float) -> void:
	if not get_parent().is_processing():
		return
	pressed_inputs.left = false
	pressed_inputs.right = false
	pressed_inputs.up = false
	pressed_inputs.down = false
	
	if not player_detector:
		return
	
	var dist := 0
	player_detector.cast_to = player.position - parent.position
	player_detector.force_raycast_update()
	if player_detector.is_colliding() and player_detector.get_collider() == player:
		last_known_position = player.position
		dist = 100
	
	if abs(last_known_position.x - parent.position.x) > dist:
		if last_known_position.x > parent.position.x:
			pressed_inputs.right = true
		elif last_known_position.x < parent.position.x:
			pressed_inputs.left = true
	
	if abs(last_known_position.y - parent.position.y) > dist:
		if last_known_position.y > parent.position.y:
			pressed_inputs.down = true
		elif last_known_position.y < parent.position.y:
			pressed_inputs.up = true
