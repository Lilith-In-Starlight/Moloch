extends RayCast2D


var timer := 0.0

var CastInfo := SpellCastInfo.new()
var spell_behavior = RayBehavior.new()

var did := false

func _ready():
	enabled = true
	CastInfo.set_position(self)
	CastInfo.set_goal()
	spell_behavior.get_angle(CastInfo.goal, position, CastInfo)
	cast_to = CastInfo.vector_from_angle(spell_behavior.angle, 1000)
	var sound_emitter := AudioStreamPlayer2D.new()
	sound_emitter.stream = preload("res://Sfx/spells/laserfire01.wav")
	sound_emitter.position = position
	sound_emitter.pitch_scale = 0.9 + float()*0.3
	get_parent().add_child(sound_emitter)
	sound_emitter.play()
	var Map :TileMap = get_tree().get_nodes_in_group("World")[0]
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)

func _physics_process(delta):
	timer += delta
	CastInfo.set_position(self)
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
