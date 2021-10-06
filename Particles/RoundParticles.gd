extends Node2D

var speed := 0.0

func _process(delta):
	position += Vector2(cos(rotation), sin(rotation)) * speed*60
	speed += delta
	if speed > 5:
		queue_free()

func _draw():
	draw_circle(Vector2.ZERO, 2+randi()%5, ColorN("white", 0.1+randf()*0.9))
