extends RigidBody2D

var frames := 0.0
var force_process := false

func _ready():
	match Items.WorldRNG.randi()%3:
		1:
			$Sprite.texture = preload("res://Sprites/Elements/Vase2.png")
			$Sprite.offset.y = -4
		2:
			$Sprite.texture = preload("res://Sprites/Elements/Vase3.png")
			$Sprite.offset.y = -4

func _physics_process(delta):
	frames += delta
	if frames > 0.2 and not force_process:
		set_physics_process(false)
	else:
		sleeping = false


func _on_screen_entered():
	sleeping = false
	force_process = true


func _on_screen_exited():
	sleeping = true
	force_process = false
