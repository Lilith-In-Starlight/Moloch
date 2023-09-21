#extends Node2D
#
#
#var WorldMap :Node2D
#var Cam :Camera2D
#
#var CastInfo := SpellCastInfo.new()
#var spell_behavior := RayBehavior.new()
#
#var timer := 0.0
#
#
#func _ready():
#	Cam = get_tree().get_nodes_in_group("Camera")[0]
#	add_child(spell_behavior)
#	spell_behavior.ray_setup(self, 124)
#	spell_behavior.connect("hit_something", self, "_on_hit_something", [])
#	spell_behavior.connect("hit_nothing", self, "_on_hit_nothing", [])
#	WorldMap = get_tree().get_nodes_in_group("World")[0]
#
#
#func _physics_process(delta):
#	spell_behavior.ray_setup(self, 124)
#	spell_behavior.cast(CastInfo)
#	CastInfo.heat_caster(1/60.0)
#
#
#	timer += delta
#	if timer > 0.5:
#		queue_free()
#
#
#
#func _on_hit_something():
#	var pos :Vector2 = spell_behavior.get_collision_point()
#	var pos2 :Vector2 = spell_behavior.get_collision_point()
#	if spell_behavior.get_collider().is_in_group("WorldPiece"):
#		CastInfo.push_caster(-(pos-position).normalized()*10)
#		pos.x = int(pos.x/8)
#		pos.y = int(pos.y/8)
#		for x in range(-2, 3):
#			for y in range(-2, 3):
#				var v := Vector2(x, y)
#				if v.length() < 2:
#					WorldMap.set_tiles_cellv(v+pos,-1)
#					CastInfo.heat_caster(1/30.0)
#
##		WorldMap.update_bitmask_region(pos-Vector2(2,2), pos+Vector2(2,2))
#	elif spell_behavior.get_collider().has_method("health_object"):
#		spell_behavior.get_collider().health_object().temp_change(5.0, CastInfo.Caster)
#		CastInfo.heat_caster(1/60.0)
#		CastInfo.push_caster(-(pos-position).normalized()*5)
#	$Line2D.points = [Vector2(0, 0), pos2-position]
#
#	if is_instance_valid(CastInfo.Caster) and CastInfo.Caster.is_in_group("Player"):
#		if Cam.position.distance_squared_to(pos2) != 0.0:
#			var inverse_distance := 1000.0/Cam.position.distance_squared_to(pos2)
#			Cam.shake_camera(inverse_distance * 6.0)
#		else:
#			Cam.shake_camera(2.0)
#
#
#func _on_hit_nothing():
#	Cam.shake_camera(1.2)
#	$Line2D.points = [Vector2(0, 0), spell_behavior.cast_to]


extends SpellManager


var rotate := 0.0
var WorldMap :Node2D

var timer := 0.0

var noise := OpenSimplexNoise.new()


func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	movement_manager = ParicleMovement.new()
	movement_manager.gravity = 0.0
	movement_manager.max_bounces = 1
	movement_manager.use_wand_speed = false
	movement_manager.limit_movement_to_collision = true
	movement_manager.max_distance = 100
	movement_manager.velocity = (CastInfo.goal - position).normalized() * 9000
	movement_manager.set_up_to(self)
	add_child(movement_manager)
	
	var hurt_on_collide := HurtOnCollide.new()
	hurt_on_collide.heat_damage = 2
	hurt_on_collide.caster = CastInfo.Caster
	add_child(hurt_on_collide)
	
	side_effects = HurtCasterModule.new()
	side_effects.caster = CastInfo.Caster
	add_child(side_effects)
	movement_manager.connect("collision_happened", self, "_on_collision_happened")
	
	var break_on_collide := DestroyWorld.new()
	movement_manager.connect("collision_happened", break_on_collide, "_on_collision_happened")
	break_on_collide.connect("destroy_tile", self, "_on_destroyed_tiles")
	add_child(break_on_collide)
	
	movement_manager.connect("collision_happened", hurt_on_collide, "_on_collision_happened")
	movement_manager.connect("request_movement", $Line2D, "_on_request_movement")
	
	var sound_emitter := AudioStreamPlayer2D.new()
	sound_emitter.stream = preload("res://Sfx/spells/laserfire01.wav")
	sound_emitter.position = position
	sound_emitter.pitch_scale = 0.9 + float()*0.3
	get_parent().add_child(sound_emitter)
	sound_emitter.play()


func _on_collision_happened(_a, _b, _c):
	if side_effects != null:
		side_effects.change_temp(0.2)

func _on_destroyed_tiles(num: int):
	if side_effects != null:
		side_effects.change_temp(num/30.0)
