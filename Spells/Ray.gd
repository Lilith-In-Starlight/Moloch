#extends Node2D
#
#
#var timer := 0.0
#
#var CastInfo := SpellCastInfo.new()
#var spell_behavior = RayBehavior.new()
#
#var did := false
#
#
#func _ready():
#	add_child(spell_behavior)
#	spell_behavior.ray_setup(self, 2000)
#	spell_behavior.connect("hit_something", self, "_on_hit_something", [], 4)
#	spell_behavior.connect("hit_nothing", self, "_on_hit_nothing", [], 4)
#	var sound_emitter := AudioStreamPlayer2D.new()
#	sound_emitter.stream = preload("res://Sfx/spells/laserfire01.wav")
#	sound_emitter.position = position
#	sound_emitter.pitch_scale = 0.9 + float()*0.3
#	get_parent().add_child(sound_emitter)
#	sound_emitter.play()
#	var Map :Node2D = get_tree().get_nodes_in_group("World")[0]
#	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)
#
#
#func _physics_process(delta):
#	timer += delta
#	CastInfo.set_position(self)
#	spell_behavior.cast(CastInfo)
#
#	if timer > 0.05:
#		queue_free()
#
#
#func _on_hit_something():
#	var col = spell_behavior.get_collider()
#	if col.has_method("health_object") and not did:
#		col.health_object().poke_hole(1, CastInfo.Caster)
#		did = true
#	$Line2D.points = [Vector2(0, 0), spell_behavior.get_collision_point() - position]
#
#
#func _on_hit_nothing():
#	$Line2D.points = [Vector2(0, 0), spell_behavior.cast_to]
#


extends SpellManager


var rotate := 0.0
var WorldMap :Node2D

var timer := 0.0

var noise := OpenSimplexNoise.new()

var CastInfo := SpellCastInfo.new()


func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	movement_manager = ParicleMovement.new()
	movement_manager.max_bounces = 1
	movement_manager.gravity = 0.0
	movement_manager.velocity = (CastInfo.goal - position).normalized() * 5000
	movement_manager.set_up_to(self)
	add_child(movement_manager)
	
	var hurt_on_collide := HurtOnCollide.new()
	hurt_on_collide.poke_holes = 1
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

