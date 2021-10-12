extends KinematicBody2D

class_name Character

signal entity_died

const COYOTE_TIME := 0.2
const INPUT_BUFFER := 0.2

enum STATES {
	GROUND,
	AIR,
	WALL,
	DEAD
}

var d_unit := 1.0

var fall_speed := 15.0
var jump_force := -370
var walk_accel := 70.0

var inputs := {
	"left" : false,
	"right" : false,
	"up" : false,
	"down" : false,
	"jump" : false,
}

var last_frame_inputs := inputs.duplicate()

var ground_coyote_time := 0.0
var lwall_coyote_time := 0.0
var rwall_coyote_time := 0.0
var ground_jump_buffer := 0.0
var wall_jump_buffer := 0.0

var speed := Vector2(0, 0)

var health := Flesh.new()

var state :int = STATES.AIR


func _ready() -> void:
	pass


func process_movement(delta:float) -> void:
	health.process_health(delta, speed)
	d_unit = delta * 60.0
	speed.y += fall_speed * d_unit
	set_collision_mask_bit(2, not input_pressed("down"))
	match state:
		STATES.AIR:
			walking()
			jumping()
			wall_jumping()
			
			if is_on_floor():
				state = STATES.GROUND
			
			if is_on_wall():
				state = STATES.WALL
		
		STATES.GROUND:
			ground_coyote_time = COYOTE_TIME
			
			walking()
			jumping()
			
			if not is_on_floor():
				state = STATES.AIR
		
		STATES.WALL:
			speed.y += fall_speed * 0.6 * -sign(speed.y)
			var left_collission := move_and_collide(Vector2(-1, 0), true, true, true)
			var right_collission := move_and_collide(Vector2(1, 0), true, true, true)
			if left_collission:
				lwall_coyote_time = COYOTE_TIME
			elif right_collission:
				rwall_coyote_time = COYOTE_TIME
			wall_jumping() 
			if not (left_collission or right_collission):
				state = STATES.AIR
			elif left_collission and input_pressed("right"):
				state = STATES.AIR
			elif right_collission and input_pressed("left"):
				state = STATES.AIR
			if is_on_floor():
				state = STATES.GROUND
		
		STATES.DEAD:
			pass
	
	ground_coyote_time -= delta
	ground_jump_buffer -= delta
	rwall_coyote_time -= delta
	lwall_coyote_time -= delta
	wall_jump_buffer -= delta
	
	speed = move_and_slide(speed, Vector2(0, -1))
	last_frame_inputs = inputs.duplicate()


func walking() -> void:
	var haxis := 0.0
	if health.broken_moving_appendages != 1 or state == STATES.AIR:
		if input_pressed("left"):
			speed.x -= walk_accel
			haxis = -1.0
		elif input_pressed("right"):
			speed.x += walk_accel
			haxis = 1.0
	
		match health.broken_moving_appendages:
			0:
				if abs(haxis)<0.5:
					speed.x *= pow(0.8, d_unit)
				elif sign(haxis)!=sign(speed.x):
					speed.x *= pow(0.9, d_unit)
				else:
					speed.x *= pow(0.75, d_unit)
			2:
				if abs(haxis)<0.5:
					speed.x *= pow(0.3, d_unit)
				elif sign(haxis)!=sign(speed.x):
					speed.x *= pow(0.3, d_unit)
				else:
					speed.x *= pow(0.3, d_unit)


func jumping():
	if input_just_pressed("jump") or ground_jump_buffer > 0.0:
		if ground_coyote_time > 0.0:
			speed.y += jump_force
			ground_coyote_time = 0.0
			ground_jump_buffer = 0.0
			state = STATES.AIR
		elif input_just_pressed("jump"):
			ground_coyote_time = 0.0
			ground_jump_buffer = INPUT_BUFFER


func wall_jumping():
	if input_just_pressed("jump") or wall_jump_buffer > 0.0:
		if lwall_coyote_time > 0.0:
			if speed.y > 0:
				speed.y = 0
			speed.y += jump_force
			speed.x -= jump_force
			lwall_coyote_time = 0.0
			rwall_coyote_time = 0.0
			wall_jump_buffer = 0.0
			state = STATES.AIR
		elif rwall_coyote_time > 0.0:
			if speed.y > 0:
				speed.y = 0
			speed.y += jump_force
			speed.x += jump_force
			lwall_coyote_time = 0.0
			rwall_coyote_time = 0.0
			wall_jump_buffer = 0.0
			state = STATES.AIR
		elif input_just_pressed("jump"):
			lwall_coyote_time = 0.0
			rwall_coyote_time = 0.0
			wall_jump_buffer = INPUT_BUFFER

func input_just_pressed(input:String) -> bool:
	return input in inputs and inputs[input] and input in last_frame_inputs and not last_frame_inputs[input]


func input_pressed(input:String) -> bool:
	return input in inputs and inputs[input]


func health_object() -> Flesh:
	return health
