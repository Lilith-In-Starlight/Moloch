extends Sprite

export var randomness := 5

func _ready():
	add_to_group("Painting")
	var lawfulness := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 0))+1.0)/2.0
	var rebelry := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 0))+1.0)/2.0
	var knowledge := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 100))+1.0)/2.0
	var mushroomness := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 200))+1.0)/2.0
	
	texture = null
	var mushroom := false
	if Items.WorldRNG.randf() < mushroomness and Items.WorldRNG.randf() > 0.1:
		mushroom = true
	if Items.WorldRNG.randf() < lawfulness and Items.WorldRNG.randf() > 0.1:
		texture = Decorations.get_sign("lawful", mushroom)
	elif Items.WorldRNG.randf() < rebelry and Items.WorldRNG.randf() > 0.1:
		texture = Decorations.get_sign("rebel", mushroom)
	
	position += Vector2(-1+Items.WorldRNG.randf()*2, -1+Items.WorldRNG.randf()*2)*randomness
	
	if Items.WorldRNG.randi() % 2 == 0:
		scale.x = -1
	
	if texture == null:
		queue_free()
		
