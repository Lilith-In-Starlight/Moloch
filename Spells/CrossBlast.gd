extends Area2D


var CastInfo := SpellCastInfo.new()
var rotate :float

var speed := 4.0

var timer := 0.0

var Map :Node2D

var has_done := false
var spell_behavior := ProjectileBehavior.new()
var vel_mult := 1.0

func _ready():
	Map = get_tree().get_nodes_in_group("World")[0] 
	CastInfo.set_position(self)
	CastInfo.set_goal()
	CastInfo.heat_caster(3.0)
	rotate = CastInfo.goal.angle_to_point(position)
	spell_behavior.velocity = (CastInfo.goal - position).normalized() * 60 * 12
	$TextureProgress.radial_initial_angle += rad2deg(rotate)
	$TextureProgress2.radial_initial_angle += rad2deg(rotate)
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)


func _physics_process(delta):
	$TextureProgress.value += delta*60*0.08*(360/3.0)
	$TextureProgress2.value += delta*60*0.08*(360/3.0)
	spell_behavior.velocity = spell_behavior.move(0, CastInfo)
	position += spell_behavior.velocity * delta
	vel_mult = move_toward(vel_mult, 0, delta)
	spell_behavior.velocity *= vel_mult
	if spell_behavior.velocity.length() < 2.0:
		timer += delta
		$CrossBlastCross.modulate.a += 0.3
		Map.play_sound(Items.EXPLOSION_SOUNDS[randi()%Items.EXPLOSION_SOUNDS.size()], position, 1.0, 0.8+randf()*0.4)
		
		for body in get_overlapping_bodies():
			if body.has_method("health_object"):
				var flesh : Flesh = body.health_object()
				if body.position.distance_to(position) != 0.0:
					flesh.temp_change(30/body.position.distance_to(position), CastInfo.Caster)
				else:
					flesh.temp_change(200, CastInfo.Caster)
				if body.position.distance_to(position) < 24:
					flesh.poke_hole(2+randi()%1, CastInfo.Caster)
				if body.position.distance_to(position) < 12:
					flesh.poke_hole(5+randi()%10, CastInfo.Caster)
				if body.position.distance_to(position) < 8:
					flesh.poke_hole(10+randi()%20, CastInfo.Caster)
				if body.get("speed"):
					if position.distance_to(body.position) != 0.0:
						body.speed += (body.position - position)*(50/position.distance_to(body.position))
				elif body.get("linear_velocity"):
					if position.distance_to(body.position) != 0.0:
						body.linear_velocity += 1/(position - body.position)*(50/position.distance_to(body.position))
	
	if timer > 0.15:
		queue_free()
		var map_pos :Vector2 = Map.world_to_map(position)
		for i in range(8):
			for x in range(-1,2):
				for y in range(-1,2):
					if abs(x)+abs(y) in [0, 1]:
						var vec1 := map_pos + Vector2(i+x, i+y)
						var vec2 := map_pos + Vector2(-i+x, i+y)
						var vec3 := map_pos + Vector2(i+x, -i+y)
						var vec4 := map_pos + Vector2(-i+x, -i+y)
						Map.set_tiles_cellv(vec1, Items.break_block(Map.get_tiles_cellv(vec1), 0.4))
						Map.set_tiles_cellv(vec2, Items.break_block(Map.get_tiles_cellv(vec1), 0.4))
						Map.set_tiles_cellv(vec3, Items.break_block(Map.get_tiles_cellv(vec1), 0.4))
						Map.set_tiles_cellv(vec4, Items.break_block(Map.get_tiles_cellv(vec1), 0.4))
		
#		Map.update_bitmask_region(map_pos-Vector2(10,10), map_pos+Vector2(10,10))


func _draw():
	draw_circle(Vector2(0, 0), 6, "#ffb5f8")
	draw_circle(Vector2(0, 0), 4, "#ffe3fc")
	
	
