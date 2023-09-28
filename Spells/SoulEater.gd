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
	add_child(movement_manager)
	movement_manager.connect("collision_happened", self, "_on_collision_happened_2")
	
	side_effects = HurtCasterModule.new()
	side_effects.caster = CastInfo.Caster
	add_child(side_effects)
	
	
	movement_manager.connect("request_movement", $Trail, "_on_request_movement")
	
	var sound_emitter := AudioStreamPlayer2D.new()
	sound_emitter.stream = preload("res://Sfx/spells/laserfire01.wav")
	sound_emitter.position = position
	sound_emitter.pitch_scale = 0.9 + float()*0.3
	get_parent().add_child(sound_emitter)
	sound_emitter.play()


func _on_collision_happened_2(collider: Node2D, _point, _normal):
	if collider.has_method("health_object"):
		if is_instance_valid(CastInfo.Caster) and CastInfo.Caster.has_method("health_object") and CastInfo.Caster.health_object().soul_module:
			CastInfo.Caster.health_object().soul_module.amount += 0.1
			collider.health_object().shatter_soul(0.1)
			$Trail.color = Color("#25ff00")
			$Trail.recolor_trail()
	else:
		CastInfo.drain_caster_soul(0.1)
		$Trail.color = Color("#e23a00")
		$Trail.recolor_trail()
