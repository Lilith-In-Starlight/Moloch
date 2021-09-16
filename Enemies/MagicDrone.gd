extends KinematicBody2D

enum STATES {
	IDLE,
	POSITIONING,
	RECOIL,
	SEARCHING,
}

var Player :KinematicBody2D

var state :int = STATES.IDLE
var speed := Vector2(0, 0)

var position_timer := 0.0

var last_seen := Vector2(0, 0)

var noise := OpenSimplexNoise.new()

var health := Flesh.new()

var first_check := false

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.seed = randi()
	Player = get_tree().get_nodes_in_group("Player")[0]
	if Player.position.distance_to(position) < 200:
		queue_free()
	

func _physics_process(delta):
	if not first_check:
		var tcol :KinematicCollision2D = move_and_collide(Vector2(0, 0), true, true, true)
		if tcol != null:
			if tcol.collider != self:
				queue_free()
		first_check = true
	$RayCast2D.cast_to = (Player.position - position).normalized()*200
	var primordial_termor := Vector2(noise.get_noise_2d(position.x, OS.get_ticks_msec()/300.0), noise.get_noise_2d(position.y, OS.get_ticks_msec()/300.0))*30
	if (health.temperature > 45.0 and health.temperature <= 60.0) or health.soul < 0.5:
		primordial_termor = Vector2(noise.get_noise_2d(position.x, OS.get_ticks_msec()/3.0), noise.get_noise_2d(position.y, OS.get_ticks_msec()/3.0))*30
	if health.temperature > 60.0 or health.soul <= 0.0 or health.poked_holes > 0:
		if health.poked_holes > 0 or health.temperature > 60.0:
			var n:Area2D = preload("res://Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		queue_free()
	match state:
		STATES.IDLE:
			speed += (primordial_termor*10.0-speed)/10.0
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider() == Player:
					last_seen = Player.position
					state = STATES.POSITIONING
			position_timer = 0.0
		STATES.POSITIONING:
			if $RayCast2D.is_colliding():
				if not $RayCast2D.get_collider() == Player:
					state = STATES.SEARCHING
				else:
					last_seen = Player.position
			else:
				state = STATES.SEARCHING
			if position.distance_to(Player.position) > 75:
				speed += (((last_seen-position).normalized()*30+primordial_termor)-speed)/10.0
			elif position.distance_to(Player.position) < 60:
				speed += ((-(last_seen-position).normalized()*30+primordial_termor)-speed)/10.0
			else:
				speed += (primordial_termor-speed)/10.0
			
			position_timer += delta
			if position_timer >= 1.0:
				state = STATES.RECOIL
				position_timer = 0.0
				speed = -(last_seen-position).normalized()*30
				var orb := preload("res://Spells/ShatteringOrb.tscn").instance()
				orb.goal = Player
				orb.position = position
				get_parent().add_child(orb)

		STATES.RECOIL:
			speed *= 0.75
			position_timer += delta
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider() == Player:
					last_seen = Player.position
			if position_timer >= 0.5:
				if $RayCast2D.is_colliding():
					if $RayCast2D.get_collider() == Player:
						state = STATES.POSITIONING
						position_timer = 0.0
					else:
						state = STATES.SEARCHING
						position_timer = 0.0
				else:
					state = STATES.SEARCHING
					position_timer = 0.0

		STATES.SEARCHING:
			position_timer += delta
			if position.distance_to(last_seen) > 75:
				speed += (((last_seen-position).normalized()*30+primordial_termor)-speed)/10.0
			elif position.distance_to(last_seen) < 60:
				speed += ((-(last_seen-position).normalized()*30+primordial_termor)-speed)/10.0
			if position_timer >= 2.5:
				state = STATES.IDLE
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider() == Player:
					last_seen = Player.position
					state = STATES.POSITIONING
					position_timer = 0.0

	speed = move_and_slide(speed)
	update()

func _draw():
	match state:
		STATES.POSITIONING:
			draw_circle(Vector2(0, 0), 8, "#0ac58a")
		_:
			draw_circle(Vector2(0, 0), 8, "#3fb58a")


func health_object():
	return health
