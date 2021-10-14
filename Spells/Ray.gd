extends RayCast2D

var rotate := 0.0

var timer := 0.0

var CastInfo := SpellCastInfo.new()

var did := false

func _ready():
	enabled = true
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.goal.angle_to_point(position)
	cast_to = Vector2(cos(rotate), sin(rotate))*1000

func _physics_process(delta):
	timer += delta
	if is_colliding():
		cast_to = get_collision_point() - position
		var col := get_collider()
		if col.has_method("health_object") and not did:
			col.health_object().poke_hole(1, CastInfo.Caster)
			did = true
		$Line2D.points = [Vector2(0, 0), get_collision_point()-position]
	else:
		$Line2D.points = [Vector2(0, 0), cast_to]
	
	if timer > 0.05:
		queue_free()
