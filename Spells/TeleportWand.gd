extends SpellManager


var rotate := 0.0
var WorldMap :Node2D

var timer := 0.0

var noise := OpenSimplexNoise.new()



func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	movement_manager = ParicleMovement.new()
	movement_manager.use_wand_speed = false
	movement_manager.shape = Items.player_hitbox
	movement_manager.max_bounces = 1
	movement_manager.gravity = 0.0
	movement_manager.velocity = (CastInfo.goal - position).normalized() * 5000
	movement_manager.set_up_to(self)
	movement_manager.collide_with_caster = false
	add_child(movement_manager)
	
	side_effects = HurtCasterModule.new()
	side_effects.caster = CastInfo.Caster
	add_child(side_effects)
	side_effects.shatter_soul(0.01)
	
	var relocate_caster := RelocateCasterModule.new()
	movement_manager.connect("request_movement", relocate_caster, "_on_request_movement")
	movement_manager.connect("collision_happened", relocate_caster, "_on_collision_happened")
	add_child(relocate_caster)
	
	movement_manager.connect("request_movement", $Trail, "_on_request_movement")
	
	var sound_emitter := AudioStreamPlayer2D.new()
	sound_emitter.stream = preload("res://Sfx/spells/laserfire01.wav")
	sound_emitter.position = position
	sound_emitter.pitch_scale = 0.9 + float()*0.3
	get_parent().add_child(sound_emitter)
	sound_emitter.play()

