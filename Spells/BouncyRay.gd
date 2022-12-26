extends RayCast2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := RayBehavior.new()
var times_done := 0

var timer := 0.0
var casted := false
var did := false

func _ready():
	add_child(spell_behavior)
	spell_behavior.ray_setup(self, 2000)
	CastInfo.set_position(self)
	CastInfo.set_goal()
	spell_behavior.get_angle(CastInfo.goal + CastInfo.goal_offset, position, CastInfo)
	cast_to = spell_behavior.get_cast_to(CastInfo)
	position += spell_behavior.get_cast_to(CastInfo).normalized()
	var Map :TileMap = get_tree().get_nodes_in_group("World")[0]
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)


func _physics_process(delta):
	timer += delta
	if is_colliding():
		var pos := get_collision_point()
		if get_collider().has_method("health_object") and not did:
			get_collider().health_object().poke_hole(1, CastInfo.Caster)
			did = true
		$RayCast2D.points = [Vector2(0, 0), pos-position]
		if times_done < 12 and timer > 0.18 and not casted:
			casted = true
			var new = load("res://Spells/BouncyRay.tscn").instance()
			new.CastInfo.Caster = self
			get_parent().add_child(new)
			enabled = false
			new.times_done = times_done + 1
	else:
		$RayCast2D.points[1] = spell_behavior.get_cast_to(CastInfo)
	if timer > 0.2:
		queue_free()


func looking_at():
	if is_colliding():
		var pos := get_collision_point()
		var normal := get_collision_normal()
		return (pos - position).bounce(normal.normalized())*20 + pos


func cast_from():
	if is_colliding():
		return get_collision_point()
