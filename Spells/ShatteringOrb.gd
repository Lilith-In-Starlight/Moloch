extends Area2D


var rotate := 0.0
var WorldMap :TileMap
var Player

var timer := 0.0

var noise := OpenSimplexNoise.new()

var goal :Node2D = null


func _ready():
	noise.seed = randi()
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	Player = get_tree().get_nodes_in_group("Player")[0]
	rotate = get_local_mouse_position().angle()
	if goal != null:
		rotate =  goal.position.angle_to_point(position)
	


func _physics_process(delta):
	timer += 0.1
	position += Vector2(cos(rotate), sin(rotate))*7.0
	rotate += noise.get_noise_3d(position.x, position.y, timer)*(timer/60.0)
	if timer < 0.3:
		for body in get_overlapping_bodies():
			_on_body_entered(body)
	if timer > 10.0:
		queue_free()


func _draw():
	draw_circle(Vector2(0, 0), 3, "#0faa68")


func _on_body_entered(body):
	if timer > 0.22:
		if body.has_method("health_object"):
			body.health_object().shatter_soul(0.3)
		queue_free()
	if body.is_in_group("World"):
		queue_free()
