extends SpellManager


var rotate := 0.0
var WorldMap :Node2D

var timer := 0.0

var noise := OpenSimplexNoise.new()



func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	movement_manager = ParicleMovement.new()
	movement_manager.max_bounces = 32
	movement_manager.gravity = 0.0
	movement_manager.velocity = (CastInfo.goal - position).normalized() * 200
	movement_manager.set_up_to(self)
	add_child(movement_manager)
	
	var hurt_on_collide := HurtOnCollide.new()
	hurt_on_collide.soul_damage = 0.1
	hurt_on_collide.caster = CastInfo.Caster
	add_child(hurt_on_collide)
	
	movement_manager.connect("collision_happened", hurt_on_collide, "_on_collision_happened")
	movement_manager.connect("request_movement", $Line2D, "_on_request_movement")
	
	var sound_emitter := AudioStreamPlayer2D.new()
	sound_emitter.stream = preload("res://Sfx/spells/laserfire01.wav")
	sound_emitter.position = position
	sound_emitter.pitch_scale = 0.9 + float()*0.3
	get_parent().add_child(sound_emitter)
	sound_emitter.play()


func _draw():
	draw_circle(Vector2(0, 0), 5, "#87ff69")
		
		
