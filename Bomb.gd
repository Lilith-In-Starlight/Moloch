extends RigidBody2D

var timer := 1.0

func _process(delta):
	timer -= delta
	if timer <= 0.0 and linear_velocity.length() < 50:
		for x in range(-8,9):
			for y in range(-8,9):
				var vec := Vector2(x+int(position.x/8), y+int(position.y/8))
				match $"../World".get_cellv(vec):
					0:
						if Vector2(x,y).length()<=5+randi()%3:
							$"../World".set_cellv(vec, -1)
		queue_free()

func one_or_other():
	if randi()%2 == 0:
		return -1
	return 1
