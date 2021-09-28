extends Area2D

var CastInfo := SpellCastInfo.new()

var strength := 10.0
var particles := []

func _ready():
	CastInfo.set_position(self)

func _physics_process(delta):
	strength -= delta
	if strength <= 0.0:
		queue_free()
	else:
		for body in get_overlapping_bodies():
			if body.get("speed"):
				body.speed += (body.position-position).normalized()*((strength*2000)/(position.distance_to(body.position)+0.001))
	
	if randf()*10 < strength:
		particles.append([Vector2(-1+randf()*2, -1+randf()*2).normalized()*2.0,0.0])
	update()

func _draw():
	var minus := 0
	for i in particles.size():
		particles[i-minus][0] *= 1.2
		particles[i-minus][1]+=0.2
		if particles[i-minus][0].length() < 1.0 or particles[i-minus][0].length() > 160:
			particles.remove(i-minus)
			minus += 1
		else:
			draw_circle(particles[i-minus][0], 1.0, ColorN("white", particles[i-minus][1]))
