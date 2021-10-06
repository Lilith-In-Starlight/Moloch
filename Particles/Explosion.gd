extends Area2D

var done := 0
var radius := 70
var timer := 0.0

var Map

func _ready():
	Map = get_tree().get_nodes_in_group("World")[0] 
	for x in range(-10,11):
		for y in range(-10,11):
			var vec := Vector2(x+int(position.x/8), y+int(position.y/8))
			if Vector2(x,y).length()<=7+randi()%4:
				Map.set_cellv(vec, Items.break_block(Map.get_cellv(vec), 0.5))
	var point := Vector2(int(position.x/8), int(position.y/8))
	Map.update_bitmask_region(point-Vector2(10,10), point+Vector2(10,10))

func _process(delta):
	radius = clamp(lerp(radius, 0, -1.5), 0, 70)
	timer += delta
	if timer > 0.5:
		queue_free()
		
	if timer > 0.1:
		modulate.a -= 0.1
	update()

func _physics_process(_delta):
	if done < 3:
		for body in get_overlapping_bodies():
			if body.has_method("health_object"):
				var flesh : Flesh = body.health_object()
				flesh.temp_change(500/body.position.distance_to(position))
				if body.position.distance_to(position) < 24:
					flesh.poke_hole(2+randi()%1)
				if body.position.distance_to(position) < 12:
					flesh.poke_hole(5+randi()%10)
				if body.position.distance_to(position) < 8:
					flesh.poke_hole(10+randi()%20)
				if body.get("speed"):
					body.speed += (body.position - position)*100
				elif body.get("linear_velocity"):
					body.linear_velocity += (position - body.position).normalized()*200/(position.distance_squared_to(body.position))
		done += 1
	else:
		queue_free()
	

func _draw():
	draw_circle(Vector2(0, 0), radius, "#ea5d00")
	draw_circle(Vector2(0, 0), radius*0.9, "#fc9e44")
	draw_circle(Vector2(0, 0), radius*0.7, "#fff0bd")
