extends Node2D

var rotate := 0.0
var WorldMap :TileMap

var timer := 0.0
var times := 0

var CastInfo := SpellCastInfo.new()


func _ready():
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	CastInfo.set_position(self)
	rotate = CastInfo.goal.angle_to_point(position)

func _process(delta):
	timer += delta
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.goal.angle_to_point(position)
	
	if timer > 0.1:
		var r := preload("res://Spells/AlveolarProjectile.tscn").instance()
		r.position = global_position
		r.rotate = rotate
		get_parent().add_child(r)
		times += 1
	
	if times > 12:
		queue_free()
