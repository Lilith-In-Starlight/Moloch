extends Sprite


func _ready():
	var lawfulness := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 0))+1.0)/2.0
	var rebelry := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 0))+1.0)/2.0
	var knowledge := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 100))+1.0)/2.0
	var mushroomness := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 200))+1.0)/2.0
	
	texture = null
	if Items.WorldRNG.randf() < lawfulness and Items.WorldRNG.randf() > 0.1:
		texture = Decorations.get_painting("lawful")
	elif Items.WorldRNG.randf() < rebelry and Items.WorldRNG.randf() > 0.1:
		texture = Decorations.get_painting("rebel")
	
	if texture == null:
		queue_free()
		
