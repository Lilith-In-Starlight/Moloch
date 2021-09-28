extends Area2D


var rotate := 0.0
var WorldMap :TileMap

var timer := 0.0

var noise := OpenSimplexNoise.new()

var CastInfo := SpellCastInfo.new()


func _ready():
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	noise.seed = randi()
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.goal.angle_to_point(position)
	


func _physics_process(delta):
	timer += 0.1
	position += Vector2(cos(rotate), sin(rotate))*7.0*(60*delta)
	rotate += noise.get_noise_3d(position.x, position.y, timer)*(timer/60.0)
	for body in get_overlapping_bodies():
		_on_body_entered(body)
	if timer > 10.0:
		queue_free()


func _draw():
	draw_circle(Vector2(0, 0), 3, "#0faa68")


func _on_body_entered(body):
	if timer > 0.32:
		if body.has_method("health_object"):
			body.health_object().shatter_soul(0.2)
		queue_free()
	if body.is_in_group("World"):
		queue_free()
