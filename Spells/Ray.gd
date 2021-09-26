extends RayCast2D

var rotate := 0.0
var Caster :Node2D

var timer := 0.0


var goal :Vector2
var did := false

func _ready():
	enabled = true
	position = Caster.position
	if Caster.has_method("cast_from"):
		position = Caster.cast_from()
	rotate = goal.angle_to_point(position)
	if Caster.name != "Player":
		set_collision_mask_bit(0, true)
	cast_to = Vector2(cos(rotate), sin(rotate))*1000

func _physics_process(delta):
	timer += delta
	if is_colliding():
		cast_to = get_collision_point() - position
		var col := get_collider()
		if col.has_method("health_object") and not did:
			col.health_object().poke_hole()
			did = true
		$Line2D.points = [Vector2(0, 0), get_collision_point()-position]
	else:
		$Line2D.points = [Vector2(0, 0), cast_to]
	
	if timer > 0.05:
		queue_free()
