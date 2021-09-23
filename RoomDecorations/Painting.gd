extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var lawfulness := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 0))+1.0)/2.0
	var rebelry := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 0))+1.0)/2.0
	var knowledge := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 100))+1.0)/2.0
	var mushroomness := ((Items.simplex_noise.get_noise_3d(global_position.x, global_position.y, 200))+1.0)/2.0
	
	if Items.WorldRNG.randf() < lawfulness and Items.WorldRNG.randf() > 0.1:
		texture = preload("res://Sprites/Elements/Decoration/Paintings/painting1.png")
	elif Items.WorldRNG.randf() < rebelry and Items.WorldRNG.randf() > 0.1:
		match Items.WorldRNG.randi() % 3:
			0:
				texture = preload("res://Sprites/Elements/Decoration/Paintings/leader_vandalized.png")
			1:
				texture = preload("res://Sprites/Elements/Decoration/Paintings/leader_vandalized2.png")
			2:
				texture = preload("res://Sprites/Elements/Decoration/Paintings/leader_vandalized3.png")
	else:
		texture = null
		queue_free()
		
