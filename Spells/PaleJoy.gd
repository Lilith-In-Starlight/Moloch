extends Area2D


var Caster :Node2D
var goal :Vector2
var move_to :Vector2
var speed :Vector2
var is_in := false
var timer := 0.0
var out := false


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Caster.position + (goal - Caster.position).normalized()*150
	move_to = Caster.position

func _physics_process(delta):
	
	$Sprite.rotation += 1.0
	
	if not out and is_instance_valid(Caster):
		if timer > 6.0 and speed.y < -2.2:
			out = true
		if timer < 6.0:
			timer += delta
		$Sprite.rotation += delta
		if speed.length() > 5:
			speed = speed.normalized()*5
		position += speed*(60*delta)
		speed = speed.move_toward(move_to-position, 0.3)
		move_to = lerp(move_to, Caster.position, 0.3)
	else:
		timer += delta
		speed.y += delta*10
		position += speed*(60*delta)
	if timer > 8.0:
		queue_free()
	
	for i in get_overlapping_bodies():
		if i.has_method("health_object"):
			i.health_object().poke_hole(1000)
	


func _on_body_entered(body):
	pass # Replace with function body.
