extends KinematicBody2D


enum STATES {
	NORMAL,
	SEARCHING,
}

var state :int = STATES.NORMAL
var Player :KinematicBody2D
var speed := Vector2(0, 0)
var noise := OpenSimplexNoise.new()
var first_check := false

func _ready():
	noise.seed = hash(self)
	Player = get_tree().get_nodes_in_group("Player")[0]
	if Player.position.distance_to(position) < 500:
		queue_free()


func _physics_process(delta):
	if not first_check:
		if Player.position.distance_to(position) < 500:
			queue_free()
		var tcol :KinematicCollision2D = move_and_collide(Vector2(0, 0), true, true, true)
		if tcol != null:
			if tcol.collider != self:
				queue_free()
		first_check = true
	
	var primordial_tremor := Vector2(noise.get_noise_2d(position.x, Engine.get_frames_drawn()), noise.get_noise_2d(position.y, Engine.get_frames_drawn()))*5
	match state:
		STATES.NORMAL:
			if Player.position.distance_to(position) > 500:
				speed = primordial_tremor
			else:
				var goal := (position - Player.position).normalized()*80 + Player.position
				speed = primordial_tremor + (goal-position).normalized()
			speed = move_and_slide(speed*60)

