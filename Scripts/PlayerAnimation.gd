extends Node2D

enum ANIMS {
	idle,
	running,
	jumping,
	falling,
	nothing,
	nlight,
}


onready var FrontLeg := $FrontLeg
onready var BackLeg := $BackLeg
onready var FrontFoot := $FrontFoot
onready var BackFoot := $BackFoot
onready var Body := $Body
onready var Head := $Head
onready var FrontArm := $FrontArm
onready var BackArm := $BackArm

var current_anim = ANIMS.idle

var time := 0.0
var pastuff := false

var blink_time := 0
var time_blink := 50
var last_pos := Vector2(0, 0)

func _ready():
	last_pos = get_parent().position

func _process(delta):
	if blink_time > time_blink:
		Head.play("default")
		time_blink = 300 + randi() % 360
		print("hm?")
		blink_time = 0
	blink_time += 1
	time += 1
	
	Head.global_position = Body.global_position + Vector2(cos(Body.rotation), sin(Body.rotation)).rotated(PI/2 * 3) * 22 + Vector2(3, 0)
	FrontArm.global_position = Body.global_position + Vector2(cos(Body.rotation - 0.02), sin(Body.rotation)).rotated(PI/2 * 3) * 18
	BackArm.global_position = Body.global_position + Vector2(cos(Body.rotation + 0.02), sin(Body.rotation)).rotated(PI/2 * 3) * 18
	match current_anim:
		ANIMS.idle:
			FrontFoot.rotation = move_toward(FrontFoot.rotation, 0, 0.5)
			BackFoot.rotation = move_toward(BackFoot.rotation, 0, 0.5)
			FrontLeg.go_to = Vector2(-10, 30) 
			BackLeg.go_to = Vector2(10, 30)
			FrontArm.go_to = Vector2(-3 + (sin(time * 0.04) *1), 5 - (sin(time * 0.1) *1))
			BackArm.go_to = Vector2(12 + (sin(time * 0.05) *1), -4 - (sin(time * 0.1) *1))
			
			position.y += (abs(sin(time * 0.1) * 2) - position.y)/2
			position.x += (abs(sin(time * 0.1) * 2) - position.y)/2
			Head.rotation = -sin(time * 0.2) * 0.05
			Body.rotation = move_toward(Body.rotation, 0, 0.1)
			if FrontLeg.position.x < 0:
				FrontLeg.position.x = move_toward(FrontLeg.position.x, -4, 2)
				BackLeg.position.x = move_toward(BackLeg.position.x, 6, 2)
			else:
				FrontLeg.position.x = move_toward(FrontLeg.position.x, 2, 2)
				BackLeg.position.x = move_toward(BackLeg.position.x, 0, 2)
		ANIMS.running:
			FrontFoot.rotation = FrontLeg.rotation
			BackFoot.rotation = BackLeg.rotation
			position.x += (0 - position.x)/2
			var running_slowness := 0.09
			var slowness_running := 1/running_slowness
			var speedness := 8
			var speedness2 := 8
			
			Body.rotation = move_toward(Body.rotation, 0.15, 0.12)
			Head.rotation = sin(time * 0.3) * 0.05
			
			position.y += ((sin(time * running_slowness * 4) * 5) - position.y)/8
			if fmod(time, PI*slowness_running) < PI*(slowness_running/4):
				FrontLeg.position.x = move_toward(FrontLeg.position.x, 0, 2)
				BackLeg.position.x = move_toward(BackLeg.position.x, 0, 2)
				BackLeg.go_to = BackLeg.go_to.move_toward(Vector2(0, 30) - Vector2.UP - position, speedness)
				FrontLeg.go_to = FrontLeg.go_to.move_toward(Vector2(0, 25) - Vector2.UP - position, speedness)
				
			elif fmod(time, PI*slowness_running) < PI*(slowness_running/4)*2:
				FrontLeg.position.x = move_toward(FrontLeg.position.x, 5, 2)
				BackLeg.position.x = move_toward(BackLeg.position.x, -3, 2)
				BackLeg.go_to = BackLeg.go_to.move_toward(Vector2(-25, 20) - Vector2.UP - position, speedness2)
				FrontLeg.go_to = FrontLeg.go_to.move_toward(Vector2(25, 20) - Vector2.UP - position, speedness2)
				
				FrontArm.go_to = FrontArm.go_to.move_toward(Vector2(-5, -3) - position, speedness/2)
				BackArm.go_to = BackArm.go_to.move_toward(Vector2(12, -4) - position, speedness/2)
			elif fmod(time, PI*slowness_running) < PI*(slowness_running/4)*3:
				FrontLeg.position.x = move_toward(FrontLeg.position.x, 0, 2)
				BackLeg.position.x = move_toward(BackLeg.position.x, 0, 2)
				BackLeg.go_to = BackLeg.go_to.move_toward(Vector2(0, 25) - Vector2.UP - position, speedness)
				FrontLeg.go_to = FrontLeg.go_to.move_toward(Vector2(0, 30) - Vector2.UP - position, speedness)
				
			else:
				FrontLeg.position.x = move_toward(FrontLeg.position.x, -3, 2)
				BackLeg.position.x = move_toward(BackLeg.position.x, 5, 2)
				BackLeg.go_to = BackLeg.go_to.move_toward(Vector2(25, 20) - Vector2.UP - position, speedness2)
				FrontLeg.go_to = FrontLeg.go_to.move_toward(Vector2(-25, 20) - Vector2.UP - position, speedness2)
				
				FrontArm.go_to = FrontArm.go_to.move_toward(Vector2(10, -2) - position, speedness/2)
				BackArm.go_to = BackArm.go_to.move_toward(Vector2(-6, -4) - position, speedness/2)
		ANIMS.nothing:
			BackLeg.go_to += last_pos - get_parent().position
			BackArm.go_to += last_pos - get_parent().position
			FrontLeg.go_to += last_pos - get_parent().position
			FrontArm.go_to += last_pos - get_parent().position
			FrontFoot.rotation = FrontLeg.rotation
			BackFoot.rotation = BackLeg.rotation
			Body.rotation = move_toward(Body.rotation, (last_pos - get_parent().position).angle() - PI/2, 0.01)
			last_pos = get_parent().position
			
		ANIMS.falling:
			position.x += (0 - position.x)/2
			position.y = move_toward(position.y, 5, 0.5)
			Body.rotation = 0
			Head.rotation += (0.3 - Head.rotation)/5
			FrontLeg.position.x = move_toward(FrontLeg.position.x, -3, 2)
			BackLeg.position.x = move_toward(BackLeg.position.x, 5, 2)
			BackLeg.go_to = BackLeg.go_to.move_toward(Vector2(6, 25), 2)
			FrontLeg.go_to = FrontLeg.go_to.move_toward(Vector2(-6, 30), 5)
			
			BackArm.go_to += last_pos - get_parent().position
			FrontArm.go_to += last_pos - get_parent().position
			
			if BackArm.go_to.y < 3:
				BackArm.go_to.y = 3
			if FrontArm.go_to.y < 3:
				FrontArm.go_to.y = 3
			last_pos = get_parent().position
			
		ANIMS.jumping:
			position.x += (0 - position.x)/2
			position.y = move_toward(position.y, 0.3, 0.1)
			Body.rotation = 0
			Head.rotation += (-0.3 - Head.rotation)/3
			FrontLeg.position.x = move_toward(FrontLeg.position.x, -3, 2)
			BackLeg.position.x = move_toward(BackLeg.position.x, 5, 2)
			BackLeg.go_to = BackLeg.go_to.move_toward(Vector2(6, 31), 5)
			FrontLeg.go_to = FrontLeg.go_to.move_toward(Vector2(-6, 31), 5)
			
			BackArm.go_to += last_pos - get_parent().position
			FrontArm.go_to += last_pos - get_parent().position
			last_pos = get_parent().position
			
		ANIMS.nlight:
			Body.rotation = move_toward(Body.rotation, -1, 0.5)
			FrontLeg.position.x = move_toward(FrontLeg.position.x, 0, 5)
			BackLeg.position.x = move_toward(FrontLeg.position.x, 0, 5)
			FrontLeg.go_to = Vector2(-10, 30) - position
			BackArm.go_to = BackArm.go_to.move_toward(Vector2(-10,10) - position, 10)
			BackLeg.go_to = BackLeg.go_to.move_toward(Vector2(10, -10) - Vector2.UP - position, 10)
		
	FrontFoot.position += ((FrontLeg.go_to) - FrontFoot.position) - position
	BackFoot.position += ((BackLeg.go_to) - BackFoot.position) - position


func _on_Head_animation_finished():
	Head.frame = 0
