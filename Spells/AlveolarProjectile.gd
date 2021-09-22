extends KinematicBody2D


var rotate := 0.0
var WorldMap :TileMap
var Caster

var timer := 0.0


var goal :Vector2


func _ready():
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	
	position += Vector2(cos(rotate), sin(rotate))*12.0
	


func _physics_process(delta):
	timer += 0.1
		
	move_and_collide(Vector2(cos(rotate), sin(rotate))*12.0*(60*delta))
	if timer < 0.3:
		for body in $Area.get_overlapping_bodies():
			_on_body_entered(body)
	if timer > 10.0:
		queue_free()
	if timer > 0.1:
		set_collision_mask_bit(0, true)
		set_collision_mask_bit(1, true)
		set_collision_mask_bit(3, true)


func _on_body_entered(body):
	if timer > 0.22:
		if body.has_method("health_object"):
			body.health_object().poke_hole()
		queue_free()
	if body.is_in_group("World"):
		queue_free()
