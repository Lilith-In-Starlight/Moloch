extends RayCast2D


var rotate := 0.0
var WorldMap :TileMap

var CastInfo := SpellCastInfo.new()

var timer := 0.0


func _ready():
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.goal.angle_to_point(position)
	cast_to = Vector2(cos(rotate), sin(rotate))*124


func _physics_process(delta):
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.goal.angle_to_point(position)
	cast_to = Vector2(cos(rotate), sin(rotate))*124
	if is_instance_valid(CastInfo.Caster):
		CastInfo.Caster.health_object().temperature += 1/60
	if is_colliding():
		var pos := get_collision_point()
		var pos2 := get_collision_point()
		if get_collider().is_in_group("World"):
			if is_instance_valid(CastInfo.Caster):
				CastInfo.Caster.speed -= (pos-position).normalized()*10
			pos.x = int(pos.x/8)
			pos.y = int(pos.y/8)
			for x in range(-2, 3):
				for y in range(-2, 3):
					var v := Vector2(x, y)
					if v.length() < 2:
						WorldMap.set_cellv(v+pos,-1)
						if is_instance_valid(CastInfo.Caster):
							CastInfo.Caster.health_object().temperature += 1/30.0
			
			WorldMap.update_bitmask_region(pos-Vector2(2,2), pos+Vector2(2,2))
		elif get_collider().has_method("health_object"):
			get_collider().health_object().temp_change(5.0)
			if is_instance_valid(CastInfo.Caster):
				CastInfo.Caster.health_object().temperature += 1/60.0
				CastInfo.Caster.health_object().temperature += 1/150.0
				CastInfo.Caster.speed -= (pos-position).normalized()*5
		$Line2D.points = [Vector2(0, 0), pos2-position]
	else:
		$Line2D.points = [Vector2(0, 0), Vector2(cos(rotate), sin(rotate))*124]
			
	timer += delta
	if timer > 0.5:
		queue_free()
			
