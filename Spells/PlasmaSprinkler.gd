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
	movement_manager.velocity = (CastInfo.goal - position).normalized() * 200
	movement_manager.speed_multiplier = 0.8
	movement_manager.set_up_to(self)
	add_child(movement_manager)
	
	var spell_spawner := SpellSpawner.new()
	add_child(spell_spawner)
	spell_spawner.rotation = 0.2
	spell_spawner.interval = 0.05
	spell_spawner.amount = 64
	spell_spawner.use_spell_as_caster = true
	spell_spawner.spell = preload("res://Spells/PlasmaBall.tscn")
	spell_spawner.spawn()
	spell_spawner.connect("finished", self, "_on_request_death")
	

func cast_from():
	print("aaa")
	return global_position
