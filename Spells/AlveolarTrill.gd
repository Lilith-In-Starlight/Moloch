extends Node2D

var rotate := 0.0
var WorldMap :TileMap
var Player

var timer := 0.0
var times := 0


var goal :Node2D = null


func _ready():
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	Player = get_tree().get_nodes_in_group("Player")[0]
	rotate = get_local_mouse_position().angle()
	if goal != null:
		rotate =  goal.position.angle_to_point(position)

func _process(delta):
	timer += delta
	if timer > 0.1:
		var r := preload("res://Spells/AlveolarProjectile.tscn").instance()
		r.position = global_position
		r.rotate = rotate
		get_parent().add_child(r)
		times += 1
	
	if times > 12:
		queue_free()
