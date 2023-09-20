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
	movement_manager.velocity = Vector2.ZERO
	movement_manager.set_up_to(self)
	add_child(movement_manager)
	
	var spell_spawner := SpellSpawner.new()
	add_child(spell_spawner)
	spell_spawner.spell = preload("res://Spells/AlveolarProjectile.tscn")
	spell_spawner.spawn()
