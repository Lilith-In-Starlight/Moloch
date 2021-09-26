extends Node2D

var rotate := 0.0
var WorldMap :TileMap
var Caster :Node2D
var goal :Vector2

var timer := 0.0
var times := 0




func _ready():
	position = Caster.position
	if Caster.has_method("cast_from"):
		position = Caster.cast_from()
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	rotate = goal.angle_to_point(position)

func _process(delta):
	timer += delta
	if is_instance_valid(Caster):
		position = Caster.position
		if Caster.has_method("cast_from"):
			position = Caster.cast_from()
		if Caster.name == "Player":
			goal = Caster.get_local_mouse_position() + Caster.position
	rotate = goal.angle_to_point(position)
	
	if timer > 0.1:
		var r := preload("res://Spells/AlveolarProjectile.tscn").instance()
		r.position = global_position
		r.rotate = rotate
		get_parent().add_child(r)
		times += 1
	
	if times > 12:
		queue_free()
