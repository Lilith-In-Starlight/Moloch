extends RayCast2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := RayBehavior.new()
var timer := 0.0
var did := false

func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	spell_behavior.get_angle(CastInfo.goal + CastInfo.goal_offset, position, CastInfo)
	cast_to = spell_behavior.get_cast_to(1000, CastInfo)
	enabled = true
	var Map :TileMap = get_tree().get_nodes_in_group("World")[0]
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)

func _physics_process(delta):
	timer += delta
	
	CastInfo.set_position(self)
	if is_colliding():
		cast_to = get_collision_point() - position
		var col := get_collider()
		if col.has_method("health_object") and not did and col.health_object().soul > 0.0:
			did = true
			if is_instance_valid(CastInfo.Caster):
				var shatter := min(col.health_object().soul, 0.025)
				CastInfo.Caster.health_object().shatter_soul(-shatter)
				col.health_object().shatter_soul(shatter, CastInfo.Caster)
		elif not did:
			CastInfo.drain_caster_soul(0.05)
			did = true
		$Line2D.points = [Vector2(0, 0), get_collision_point()-position]
	else:
		$Line2D.points = [Vector2(0, 0), cast_to]
	
	if timer > 0.05:
		queue_free()
