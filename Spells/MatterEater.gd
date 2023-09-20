extends SpellManager

const RoundParticles := preload("res://Particles/MagicDust.tscn")
const AREA := 4


var rotate := 0.0
var WorldMap :Node2D

var timer := 0.0

var noise := OpenSimplexNoise.new()


var break_on_collide :DestroyWorld
onready var Map = get_tree().get_nodes_in_group("World")[0]

func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	movement_manager = ParicleMovement.new()
	movement_manager.speed_multiplier = 1.1
	movement_manager.gravity = 0.0
	movement_manager.do_bounces = false
	movement_manager.max_bounces = 1
	movement_manager.velocity = (CastInfo.goal - position).normalized() * 100
	movement_manager.connect("request_movement", self, "_on_request_movement")
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "modulate:a", 0.0, 0.45)
	tween.connect("finished", self, "_on_request_death")
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
	break_on_collide.radius = 5
	break_on_collide.connect("destroy_tile", self, "_on_destroyed_tiles")
	add_child(break_on_collide)
	
	movement_manager.connect("collision_happened", hurt_on_collide, "_on_collision_happened")
	
	var sound_emitter := AudioStreamPlayer2D.new()
	sound_emitter.stream = preload("res://Sfx/spells/laserfire01.wav")
	sound_emitter.position = position
	sound_emitter.pitch_scale = 0.9 + float()*0.3
	get_parent().add_child(sound_emitter)
	sound_emitter.play()


func _process(delta: float) -> void:
	if randf() < 0.3:
		var n = RoundParticles.instance()
		n.position = position
		n.modulate = ColorN("mediumorchid")
		get_parent().add_child(n)
	
	for x in range(-AREA,AREA+1):
		for y in range(-AREA,AREA+1):
			var vec := Vector2(x+int(position.x/8), y+int(position.y/8))
			if Vector2(x,y).length()<=AREA:
				Map.set_tiles_cellv(vec, Items.break_block(Map.get_tiles_cellv(vec), 0.5))
				CastInfo.heat_caster((0.01 / (0.08 + 0.3)) * delta)


func _on_collision_happened(_a, _b, _c):
	if side_effects != null:
		side_effects.change_temp(0.2)


func _on_destroyed_tiles(num: int):
	if side_effects != null:
		side_effects.change_temp(num/30.0)

