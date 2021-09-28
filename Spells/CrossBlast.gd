extends Area2D


var CastInfo := SpellCastInfo.new()
var rotate :float

var speed := 4.0

var timer := 0.0


func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.goal.angle_to_point(position)
	$TextureProgress.radial_initial_angle += rad2deg(rotate)
	$TextureProgress2.radial_initial_angle += rad2deg(rotate)


func _physics_process(delta):
	$TextureProgress.value += delta*60*0.08*(360/3.0)
	$TextureProgress2.value += delta*60*0.08*(360/3.0)
	position += Vector2(cos(rotate), sin(rotate))*speed*delta*60
	speed = move_toward(speed, 0, delta*60*0.08)
	timer += delta
	
	if speed < 0.01:
		$CrossBlastCross.modulate.a += 0.3
			
		for body in get_overlapping_bodies():
			if body.has_method("health_object"):
				var flesh : Flesh = body.health_object()
				if body.position.distance_to(position) != 0.0:
					flesh.temp_change(30/body.position.distance_to(position))
				else:
					flesh.temp_change(200)
				if body.position.distance_to(position) < 24:
					flesh.poke_hole(2+randi()%1)
				if body.position.distance_to(position) < 12:
					flesh.poke_hole(5+randi()%10)
				if body.position.distance_to(position) < 8:
					flesh.poke_hole(10+randi()%20)
				if body.get("speed"):
					if position.distance_to(body.position) != 0.0:
						body.speed += (body.position - position)*(50/position.distance_to(body.position))
				elif body.get("linear_velocity"):
					if position.distance_to(body.position) != 0.0:
						body.linear_velocity += 1/(position - body.position)*(50/position.distance_to(body.position))
	
	if timer > 0.95:
		queue_free()


func _draw():
	draw_circle(Vector2(0, 0), 6, "#ffb5f8")
	draw_circle(Vector2(0, 0), 4, "#ffe3fc")
	
	