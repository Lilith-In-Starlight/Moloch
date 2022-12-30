extends Area2D


var rotate := 0.0
var WorldMap :Node2D

var timer := 0.0

var noise := OpenSimplexNoise.new()

var CastInfo := SpellCastInfo.new()
var spell_behavior := ProjectileBehavior.new()

func _ready():
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	noise.seed = randi()
	CastInfo.set_position(self)
	CastInfo.set_goal()
	spell_behavior.velocity = spell_behavior.get_initial_velocity(self)
	rotate = 0
	var sound_emitter := AudioStreamPlayer2D.new()
	sound_emitter.stream = preload("res://Sfx/spells/laserfire01.wav")
	sound_emitter.position = position
	sound_emitter.pitch_scale = 0.9 + float()*0.3
	get_parent().add_child(sound_emitter)
	sound_emitter.play()
	WorldMap.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)
	


func _physics_process(delta):
	timer += 0.1
	spell_behavior.velocity = spell_behavior.velocity.rotated(rotate)
	position += spell_behavior.move(0.01, CastInfo)
	rotate = noise.get_noise_3d(position.x, position.y, timer)*(timer/60.0)
	for body in get_overlapping_bodies():
		_on_body_entered(body)
	if timer > 10.0:
		queue_free()


func _draw():
	draw_circle(Vector2(0, 0), 3, "#0faa68")


func _on_body_entered(body):
	if timer > 0.32:
		if body.has_method("health_object"):
			body.health_object().shatter_soul(0.2, CastInfo.Caster)
		queue_free()
	if body.is_in_group("WorldPiece"):
		queue_free()
