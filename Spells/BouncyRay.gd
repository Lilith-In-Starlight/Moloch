extends RayCast2D


var CastInfo := SpellCastInfo.new()
var rotate := 0.0
var times_done := 0

var timer := 0.0
var casted := false
var did := false

func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.get_angle(self)
	cast_to = Vector2(cos(rotate), sin(rotate))*2000
	position += Vector2(cos(rotate), sin(rotate))
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
			new.add_child(new.CastInfo)
			get_parent().add_child(new)
			enabled = false
			new.times_done = times_done + 1
	else:
		$RayCast2D.points[1] = Vector2(cos(rotate), sin(rotate))*2000
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
