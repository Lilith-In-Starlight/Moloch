extends KinematicBody2D

enum states {
	LAND,
	AIR,
	FLYING,
	DEAD,
}

var speed := Vector2(0, 0)

var state :int = states.LAND

func _physics_process(delta):
	match state:
		states.LAND:
			speed.y
	speed = move_and_slide(speed, Vector2.UP)
