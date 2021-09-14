extends RayCast2D


var rotate := 0.0
var WorldMap :TileMap
var Player

var timer := 0.0

func _ready():
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	Player = get_tree().get_nodes_in_group("Player")[0]
	rotate = get_local_mouse_position().angle()
	cast_to = Vector2(cos(rotate), sin(rotate))*1000


func _physics_process(delta):
	position = Player.position
	rotate = get_local_mouse_position().angle()
	cast_to = Vector2(cos(rotate), sin(rotate))*30000
	Player.temperature += 1/60.0
	if is_colliding():
		if get_collider().is_in_group("World"):
			var pos := get_collision_point()
			Player.speed -= (pos-position).normalized()*30
			$Line2D.points = [Vector2(0, 0), pos-position]
			pos.x = int(pos.x/8)
			pos.y = int(pos.y/8)
			for x in range(-3, 4):
				for y in range(-3, 4):
					var v := Vector2(x, y)
					if v.length() < 3:
						WorldMap.set_cellv(v+pos,-1)
						Player.temperature += 1/60.0
	else:
		$Line2D.points = [Vector2(0, 0), Vector2(cos(rotate), sin(rotate))*1000]
			
	timer += delta
	if timer > 0.5:
		queue_free()
			
