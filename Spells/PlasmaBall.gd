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
	movement_manager.max_distance = 500
	movement_manager.velocity = (CastInfo.goal - position).normalized() * 200
	movement_manager.set_up_to(self)
	add_child(movement_manager)
