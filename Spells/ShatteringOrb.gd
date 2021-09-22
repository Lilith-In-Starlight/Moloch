extends Area2D


var rotate := 0.0
var WorldMap :TileMap
var Caster :Node2D

var timer := 0.0

var noise := OpenSimplexNoise.new()

var goal :Vector2 = Vector2(0, 0)


func _ready():
	noise.seed = randi()
	position = Caster.position
	WorldMap = get_tree().get_nodes_in_group("World")[0]
	rotate = goal.angle_to_point(position)
	if Caster.name != "Player":
		set_collision_mask_bit(0, true)
	


func _physics_process(delta):
	timer += 0.1
	position += Vector2(cos(rotate), sin(rotate))*7.0*(60*delta)
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
