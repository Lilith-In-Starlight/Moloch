extends RayCast2D

var rotate := 0.0
var Player

var timer := 0.0


var goal :Node2D = null


func _ready():
	enabled = true
	Player = get_tree().get_nodes_in_group("Player")[0]
	rotate = get_local_mouse_position().angle()
	if goal != null:
		rotate =  goal.position.angle_to_point(position)
		set_collision_mask_bit(0, true)
	cast_to = Vector2(cos(rotate), sin(rotate))*1000

func _physics_process(delta):
	timer += delta
	if is_colliding():
		cast_to = get_collision_point() - position
		var col := get_collider()
		if col.has_method("health_object"):
			col.health_object().poke_hole()
		$Line2D.points = [Vector2(0, 0), get_collision_point()-position]
	else:
		$Line2D.points = [Vector2(0, 0), cast_to]
	
	if timer > 0.05:
		queue_free()
