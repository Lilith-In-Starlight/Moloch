extends SpellManager


var rotate := 0.0
var WorldMap :Node2D

var timer := 0.0

var noise := OpenSimplexNoise.new()



func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	movement_manager = ParicleMovement.new()
	movement_manager.max_bounces = 1
	movement_manager.velocity = (CastInfo.last_known_looking_at - position).normalized() * 300
	movement_manager.gravity = 500
	movement_manager.set_up_to(self)
	add_child(movement_manager)
	
	var hurt_on_collide := HurtOnCollide.new()
	hurt_on_collide.heat_damage = -12.0 - randf() * 6.0
	hurt_on_collide.caster = CastInfo.Caster
	add_child(hurt_on_collide)
	
	movement_manager.connect("collision_happened", hurt_on_collide, "_on_collision_happened")
	
	var sound_emitter := AudioStreamPlayer2D.new()
	sound_emitter.stream = preload("res://Sfx/spells/laserfire01.wav")
	sound_emitter.position = position
	sound_emitter.pitch_scale = 0.9 + float()*0.3
	get_parent().add_child(sound_emitter)
	sound_emitter.play()


func _draw():
	draw_circle(Vector2(0, 0), 3, "#0faa68")
