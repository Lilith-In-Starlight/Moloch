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


var speed := Vector2(0, 0)

var health := Flesh.new()

var state :int = STATES.AIR


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	d_unit = delta * 60.0
	speed.y += fall_speed * d_unit
	match state:
		STATES.AIR:
			walking()
			jumping()
			
			if is_on_floor():
				state = STATES.GROUND
		
		STATES.GROUND:
			ground_coyote_time = COYOTE_TIME
			
			walking()
			jumping()
			
			if not is_on_floor():
				state = STATES.AIR
		
		STATES.WALL:
			pass
		
		STATES.DEAD:
			pass
	
	ground_coyote_time -= delta
	ground_jump_buffer -= delta
	
	speed = move_and_slide(speed, Vector2(0, -1))


func walking() -> void:
	var haxis := 0.0
	if input_pressed("left"):
		speed.x -= walk_accel
		haxis = -1.0
	elif input_pressed("right"):
		speed.x += walk_accel
		haxis = 1.0
	
	match state:
		STATES.GROUND:
			if abs(haxis)<0.5:
				speed.x *= pow(0.8, d_unit)
			elif sign(haxis)!=sign(speed.x):
				speed.x *= pow(0.9, d_unit)
			else:
				speed.x *= pow(0.75, d_unit)
		STATES.AIR:
			if abs(haxis)<0.5:
				speed.x *= pow(0.85, d_unit)
			elif sign(haxis)!=sign(speed.x):
				speed.x *= pow(0.9, d_unit)
			else:
				speed.x *= pow(0.8, d_unit)


func jumping():
	if input_just_pressed("jump") or ground_jump_buffer > 0.0:
		if ground_coyote_time > 0.0:
			speed.y -= jump_force
			ground_coyote_time = 0.0
			state = STATES.AIR
		else:
			ground_jump_buffer = INPUT_BUFFER

func input_just_pressed(input:String) -> bool:
	return input in inputs and inputs[input] and input in last_frame_inputs and not last_frame_inputs[input]


func input_pressed(input:String) -> bool:
	return input in inputs and inputs[input]
