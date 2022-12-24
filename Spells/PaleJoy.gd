extends Area2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := ProjectileBehavior.new()

var move_to :Vector2
var speed :Vector2
var is_in := false
var timer := 0.0
var out := false
var start_fall := false
var grav := 0.0
var force := Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	CastInfo.set_goal()
	position = CastInfo.Caster.position + (CastInfo.goal - CastInfo.Caster.position).normalized()*50
	spell_behavior.velocity = (CastInfo.goal - position).normalized() * 60 * CastInfo.projectile_speed * 3
	move_to = CastInfo.Caster.position
	
	yield(get_tree().create_timer(6.0), "timeout")
	start_fall = true
	yield(get_tree().create_timer(6.0), "timeout")
	queue_free()

func _physics_process(delta):
	$Sprite.rotation += 1.0
	if start_fall and spell_behavior.velocity.y > 20:
		grav += delta * 60
		force = force.move_toward(Vector2(), 5*delta*60)
	else:
		move_to = move_to.move_toward(CastInfo.Caster.position, 10*delta*60)
		force = force.move_toward((move_to - position)*0.5, 5*delta*60)
	
	
	position += spell_behavior.move(grav, CastInfo, force) * delta
	if spell_behavior.velocity.length() > 450:
		spell_behavior.velocity = spell_behavior.velocity.normalized() * 450
	
	for i in get_overlapping_bodies():
		if i.has_method("health_object"):
			i.health_object().poke_hole(1000, CastInfo.Caster)

