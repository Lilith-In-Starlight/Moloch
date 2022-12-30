extends KinematicBody2D


var rotate := 0.0
var WorldMap :Node2D
var Caster
var CastInfo :SpellCastInfo

var timer := 0.0


var goal :Vector2
var spell_behavior := ProjectileBehavior.new()

func _ready():
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	CastInfo.set_goal()
	
	position += Vector2(cos(rotate), sin(rotate))*12.0
	spell_behavior.velocity = (CastInfo.goal - position).normalized() * CastInfo.get_wand_projectile_speed() * 60 * 2.5


func _physics_process(delta):
	timer += 0.1
	for body in $Area.get_overlapping_bodies():
		_on_body_entered(body)
	if timer > 10.0:
		queue_free()
	spell_behavior.velocity = move_and_slide(spell_behavior.move(0.2, CastInfo))


func _on_body_entered(body):
	if timer > 0.22:
		if body.has_method("health_object"):
			body.health_object().poke_hole(1, Caster)
		queue_free()
	if body.is_in_group("WorldPiece"):
		queue_free()
