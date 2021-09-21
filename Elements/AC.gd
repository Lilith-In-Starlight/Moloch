extends RigidBody2D


var WorldMap :TileMap
var to_change := []
var frames := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	WorldMap = get_tree().get_nodes_in_group("World")[0]


func _physics_process(delta):
	if frames < 3:
		for i in $Area2D.get_overlapping_bodies():
			_on_body_entered(i)
	frames += 1
	for i in to_change:
		if is_instance_valid(i):
			if i.position.distance_to(position) > 500:
				to_change.erase(i)
			else:
				i.health_object().temperature = move_toward(i.health_object().temperature, 25, 0.25)
		else:
			to_change.erase(i)
	if get_parent().get_cellv(get_parent().world_to_map(position) + Vector2(0, -2)) == -1:
		gravity_scale = 10.0
		sleeping = false


func _on_body_entered(body):
	if body.has_method("health_object") and not to_change.has(body):
		to_change.append(body)
