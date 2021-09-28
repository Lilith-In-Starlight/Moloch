extends RayCast2D


var CastInfo := SpellCastInfo.new()
var angle := 0.0
var timer := 0.0
var did := false

func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	angle = CastInfo.get_angle(self)
	cast_to = Vector2(cos(angle), sin(angle))*1000
	enabled = true

func _physics_process(delta):
	timer += delta
	if is_colliding():
		cast_to = get_collision_point() - position
		var col := get_collider()
		if col.has_method("health_object") and not did and col.health_object().soul > 0.0:
			did = true
			if is_instance_valid(CastInfo.Caster):
				var shatter := min(col.health_object().soul, 0.1)
				CastInfo.Caster.health_object().shatter_soul(-shatter)
				col.health_object().shatter_soul(shatter)
		elif is_instance_valid(CastInfo.Caster) and not did:
			CastInfo.Caster.health_object().shatter_soul(0.1)
			did = true
		$Line2D.points = [Vector2(0, 0), get_collision_point()-position]
	else:
		$Line2D.points = [Vector2(0, 0), cast_to]
	
	if timer > 0.05:
		queue_free()
