extends Area2D

var done := false
var radius := 70
var timer := 0.0

var Map

func _ready():
	Map = get_tree().get_nodes_in_group("World")[0]
	for x in range(-10,11):
		for y in range(-10,11):
			var vec := Vector2(x+int(position.x/8), y+int(position.y/8))
			match Map.get_cellv(vec):
				0:
					if Vector2(x,y).length()<=7+randi()%4:
						Map.set_cellv(vec, -1)

func _process(delta):
	radius = clamp(lerp(radius, 0, -1.5), 0, 70)
	print(radius)
	timer += delta
	if timer > 0.5:
		queue_free()
		
	if timer > 0.1:
		modulate.a -= 0.1
	update()

func _physics_process(delta):
	if !done:
		for body in get_overlapping_bodies():
			if body.has_method("health_object"):
				var flesh : Flesh = body.health_object()
				flesh.temp_change(200/body.position.distance_to(position))
				if body.position.distance_to(position) < 24:
					flesh.poke_hole(1+randi()%1)
				if body.position.distance_to(position) < 12:
					flesh.poke_hole(1+randi()%3)
		done = true
	

func _draw():
	draw_circle(Vector2(0, 0), radius, "#ea5d00")
	draw_circle(Vector2(0, 0), radius*0.9, "#fc9e44")
	draw_circle(Vector2(0, 0), radius*0.7, "#fff0bd")
