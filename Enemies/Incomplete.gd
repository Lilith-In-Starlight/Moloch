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
var last_seen := Vector2(0, 0)
var search_time := 0.0


func _ready():
	noise.seed = hash(self)
	Player = get_tree().get_nodes_in_group("Player")[0]
	if Player.position.distance_to(position) < 500:
		queue_free()


func _physics_process(delta):
	var frames := Engine.get_frames_drawn()
	$Senses.cast_to = speed
	$Eye.cast_to = (Player.position-position).normalized()*500
	if not first_check:
		if Player.position.distance_to(position) < 500:
			queue_free()
		var tcol :KinematicCollision2D = move_and_collide(Vector2(0, 0), true, true, true)
		if tcol != null:
			if tcol.collider != self:
				queue_free()
		first_check = true
	
	var primordial_tremor := Vector2(noise.get_noise_2d(position.x, frames), noise.get_noise_2d(position.y, frames))*5
	match state:
		STATES.NORMAL:
			if $Eye.is_colliding() and $Eye.get_collider() == Player:
				var goal := (position - Player.position).normalized()*130 + Player.position
				speed = lerp(speed, primordial_tremor*30 + (goal - position), 0.2)
				last_seen = Player.position
			else:
				speed = lerp(speed, primordial_tremor*60, 0.2)
				if last_seen != Vector2(0, 0):
					state = STATES.SEARCHING
					search_time = 0.0
			speed = move_and_slide(speed)
		
		STATES.SEARCHING:
			search_time += delta
			if $Eye.is_colliding() and $Eye.get_collider() == Player:
				state = STATES.NORMAL
			else:
				speed = lerp(speed, primordial_tremor*20 + (last_seen - position), 0.2)
			
			if search_time > 12.0:
				state = STATES.NORMAL
				last_seen = Vector2(0, 0)
			speed = move_and_slide(speed)

