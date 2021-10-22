extends Area2D

var done := 0
var radius := 70
var timer := 0.0
var dmg_multi := 1.0
var area_of_effect := 10

var Map


func _ready():
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate(true)
	Map = get_tree().get_nodes_in_group("World")[0]
	dmg_multi = area_of_effect/10.0 
	radius *= dmg_multi
	$CollisionShape2D.shape.radius *= dmg_multi
	for x in range(-area_of_effect,area_of_effect+1):
		for y in range(-area_of_effect,area_of_effect+1):
			var vec := Vector2(x+int(position.x/8), y+int(position.y/8))
			if Vector2(x,y).length()<=area_of_effect*0.7+randi()%4:
				Map.set_cellv(vec, Items.break_block(Map.get_cellv(vec), 0.5))
	var point := Vector2(int(position.x/8), int(position.y/8))
	Map.update_bitmask_region(point-Vector2(area_of_effect,area_of_effect), point+Vector2(area_of_effect,area_of_effect))
	
	Map.play_sound(Items.EXPLOSION_SOUNDS[randi()%Items.EXPLOSION_SOUNDS.size()], position, 1.0, 0.8+randf()*0.4)

func _process(delta):
	radius = clamp(lerp(radius, 0, -1.5), 0, 70*dmg_multi)
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
				flesh.temp_change(500*dmg_multi/body.position.distance_to(position))
				if body.position.distance_to(position) < 24*dmg_multi:
					flesh.poke_hole(2+randi()%1)
				if body.position.distance_to(position) < 12*dmg_multi:
					flesh.poke_hole(5+randi()%10)
				if body.position.distance_to(position) < 8*dmg_multi:
					flesh.poke_hole(10+randi()%20)
				if body.get("speed"):
					body.speed += (body.position - position)*100*dmg_multi
				elif body.get("linear_velocity"):
					body.linear_velocity += (position - body.position).normalized()*200*dmg_multi/(position.distance_squared_to(body.position))
		done += 1
	else:
		queue_free()
	

func _draw():
	draw_circle(Vector2(0, 0), radius, "#ea5d00")
	draw_circle(Vector2(0, 0), radius*0.9, "#fc9e44")
	draw_circle(Vector2(0, 0), radius*0.7, "#fff0bd")
