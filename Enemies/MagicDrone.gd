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

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.seed = randi()
	Player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	$RayCast2D.cast_to = Player.position - position
	var primordial_termor := Vector2(noise.get_noise_1d(position.x), noise.get_noise_1d(position.y))*20
	
#	match state:
#		STATES.IDLE:
#			if $RayCast2D.is_colliding():
#				if $RayCast2D.get_collider() == Player:
#					last_seen = Player.position
#					state = STATES.POSITIONING
#			position_timer = 0.0
#		STATES.POSITIONING:
#			if $RayCast2D.is_colliding():
#				if not $RayCast2D.get_collider() == Player:
#					state = STATES.SEARCHING
#				else:
#					last_seen = Player.position
#			else:
#				state = STATES.SEARCHING
#			if position.distance_to(Player.position) > 75:
#				speed.move_toward((Player.position-position).normalized()*30+primordial_termor, 5)
#			elif position.distance_to(Player.position) < 60:
#				speed.move_toward(-(Player.position-position).normalized()*30+primordial_termor, 5)
#
#			position_timer += delta
#			if position_timer >= 1.0:
#				state = STATES.RECOIL
#				position_timer = 0.0
#
#		STATES.RECOIL:
#			position_timer += delta
#			if $RayCast2D.is_colliding():
#				if $RayCast2D.get_collider() == Player:
#					last_seen = Player.position
#			if position_timer >= 0.5:
#				if $RayCast2D.is_colliding():
#					if $RayCast2D.get_collider() == Player:
#						state = STATES.POSITIONING
#						position_timer = 0.0
#					else:
#						state = STATES.SEARCHING
#						position_timer = 0.0
#				else:
#					state = STATES.SEARCHING
#					position_timer = 0.0
#
#		STATES.SEARCHING:
#			position_timer += delta
#			if position.distance_to(last_seen) > 75:
#				speed.move_toward((last_seen-position).normalized()*30+primordial_termor, 5)
#			elif position.distance_to(last_seen) < 60:
#				speed.move_toward(-(last_seen-position).normalized()*30+primordial_termor, 5)
#			if position_timer >= 2.5:
#				state = STATES.IDLE
#			if $RayCast2D.is_colliding():
#				if $RayCast2D.get_collider() == Player:
#					last_seen = Player.position
#					state = STATES.POSITIONING
#					position_timer = 0.0
#
#	speed = move_and_slide(speed)
	update()

func _draw():
	match state:
		STATES.POSITIONING:
			draw_circle(Vector2(0, 0), 8, "#0ac58a")
		_:
			draw_circle(Vector2(0, 0), 8, "#0fb58a")
	
