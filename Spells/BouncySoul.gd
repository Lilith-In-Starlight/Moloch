extends Area2D

onready var Ray := $GoingTo

var CastInfo := SpellCastInfo.new()

var rotate := 0.0
var speed :Vector2
var flip := false
var dtimer := 0.0

func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.get_angle(self)
	speed = Vector2(cos(rotate), sin(rotate))*5.0
	Ray.cast_to = speed

func _physics_process(delta):
	Ray.cast_to = speed * delta * 60
	if not Ray.is_colliding():
		position += speed * delta * 60
		flip = false
	elif not flip:
		if Ray.get_collider().has_method("health_object"):
			Ray.get_collider().health_object().shatter_soul(0.1, CastInfo.Caster)
		position = lerp(position, Ray.get_collision_point(), 0.99)
		if Ray.get_collision_normal() == Vector2(0, 0):
			queue_free()
		else:
			speed = speed.bounce(Ray.get_collision_normal().normalized())*1.02
		position += speed * delta * 60
		flip = true
		dtimer += 0.05
		update()
	else:
		dtimer += 0.1
		update()
	
	if dtimer > 0.5:
		queue_free()

func _draw():
	draw_circle(Vector2(0, 0), (0.5-dtimer)*2*5, "#87ff69")
		
		
