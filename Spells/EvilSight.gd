extends RayCast2D


var rotate := 0.0
var WorldMap :TileMap
var Player

var timer := 0.0

func _ready():
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	Player = get_tree().get_nodes_in_group("Player")[0]
	rotate = get_local_mouse_position().angle()
	cast_to = Vector2(cos(rotate), sin(rotate))*124


func _physics_process(delta):
	position = Player.position
	rotate = get_local_mouse_position().angle()
	cast_to = Vector2(cos(rotate), sin(rotate))*124
	Player.health.temperature += 1/120
	if is_colliding():
		var pos := get_collision_point()
		if get_collider().is_in_group("World"):
			Player.speed -= (pos-position).normalized()*10
			$Line2D.points = [Vector2(0, 0), pos-position]
			pos.x = int(pos.x/8)
			pos.y = int(pos.y/8)
			for x in range(-2, 3):
				for y in range(-2, 3):
					var v := Vector2(x, y)
					if v.length() < 2:
						WorldMap.set_cellv(v+pos,-1)
						Player.health.temperature += 1/120.0
		elif get_collider().has_method("health_object"):
			get_collider().health_object().temp_change(5.0)
			Player.health.temperature += 1/60.0
			Player.health.temperature += 1/150.0
			Player.speed -= (pos-position).normalized()*5
			$Line2D.points = [Vector2(0, 0), pos-position]
	else:
		$Line2D.points = [Vector2(0, 0), Vector2(cos(rotate), sin(rotate))*124]
			
	timer += delta
	if timer > 0.5:
		queue_free()
			
