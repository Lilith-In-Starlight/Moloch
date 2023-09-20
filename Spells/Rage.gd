extends SpellManager


var rotate := 0.0
var WorldMap :Node2D

var timer := 0.0

var noise := OpenSimplexNoise.new()


func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	movement_manager = ParicleMovement.new()
	movement_manager.shape = Items.default_circle_radius_one
	movement_manager.gravity = 0.0
	movement_manager.max_bounces = 1
	movement_manager.velocity = (CastInfo.goal - position).normalized() * 1000
	movement_manager.set_up_to(self)
	add_child(movement_manager)
	
	
	var hurt_on_collide := HurtOnCollide.new()
	hurt_on_collide.poke_holes = 1
	hurt_on_collide.caster = CastInfo.Caster
	add_child(hurt_on_collide)
	
	var explode_on_collide := ExplodeOnCollide.new()
	add_child(explode_on_collide)
	movement_manager.connect("collision_happened", explode_on_collide, "_on_collision_happened")
	
	movement_manager.connect("collision_happened", hurt_on_collide, "_on_collision_happened")
	
	var sound_emitter := AudioStreamPlayer2D.new()
	sound_emitter.stream = preload("res://Sfx/spells/laserfire01.wav")
	sound_emitter.position = position
	sound_emitter.pitch_scale = 0.9 + float()*0.3
	get_parent().add_child(sound_emitter)
	sound_emitter.play()

