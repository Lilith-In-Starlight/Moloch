extends KinematicBody2D

enum STATES {
	ON_GROUND,
	ON_AIR,
	ON_WALL,
}

const WALK_ACCEL := 90.0
const JUMP_ACCEL := -370.0

var Cam :Camera2D

var gravity_accel := 15.0
var gravity_direction := Vector2(0, 1)

var speed := Vector2()

var state :int = STATES.ON_AIR

var speed_before_collision := Vector2(0, 0)
var jump_buffer := 0.2
var coyote_time := 0.2
var lwjump_buffer := 0.2
var rwjump_buffer := 0.2

var health := Items.player_health

func _ready():
	Cam = get_tree().get_nodes_in_group("Camera")[0]

func _process(delta):
	var coffset := get_local_mouse_position()/4.0
	Cam.offset += (coffset-Cam.offset)/10.0
	if health.temperature > 145 or health.soul <= 0.0 or health.blood <= 0.0:
		get_tree().reload_current_scene()
	if Items.player_items.has("thickblood"):
		Items.player_items.erase("thickblood")
		health.max_blood *= 2.0
		health.blood *= 2.0
		
	if Items.player_items.has("heal"):
		Items.player_items.erase("heal")
		health.soul = 1.0
		health.blood = health.max_blood
		health.temperature = 30.0
		health.poked_holes = 0
		health.broken_moving_appendages = 0
	
	if Items.player_wands[Items.selected_wand] is Wand and Input.is_action_just_pressed("Interact1") and not Items.player_wands[Items.selected_wand].running:
		Items.player_wands[Items.selected_wand].running = true
	
	if Input.is_action_just_released("scrollup"):
		Items.selected_wand -= 1
		if Items.selected_wand < 0:
			Items.selected_wand = 5
		
	elif Input.is_action_just_released("scrolldown"):
		Items.selected_wand = (Items.selected_wand + 1) % 6
		
func _physics_process(delta):
	health.blood -= health.poked_holes * (0.5+randf())*0.0005
	set_collision_mask_bit(2, not Input.is_key_pressed(KEY_S))
	
	
	if not Items.player_items.has("wings"):
		speed.y += gravity_accel * gravity_direction.y
		match state:
			STATES.ON_GROUND:
				coyote_time = 0.2
				if not is_on_floor():
					state = STATES.ON_AIR
				
				if (Input.is_action_just_pressed("jump") or jump_buffer > 0.0) and health.broken_moving_appendages < 2:
					speed.y += JUMP_ACCEL * gravity_direction.y
					coyote_time = 0.0
					if health.broken_moving_appendages == 1: 
						speed.y *= 0.6+randf()*0.4
					state = STATES.ON_AIR
					health.temperature += 0.002
				jump_buffer = 0.0
				
				if health.broken_moving_appendages == 0:
					var haxis := 0.0
					if Input.is_action_pressed("left"):
						speed.x -= WALK_ACCEL
						haxis = -1.0
						health.temperature += 0.001
					elif Input.is_action_pressed("right"):
						speed.x += WALK_ACCEL
						haxis = 1.0
						health.temperature += 0.001
					else:
						health.temperature = move_toward(health.temperature, 30, 0.002)
					if abs(haxis)<0.5:
						speed.x *= pow(0.8, delta*60)
					elif sign(haxis)!=sign(speed.x):
						speed.x *= pow(0.9, delta*60)
					else:
						speed.x *= pow(0.75, delta*60)
				elif health.broken_moving_appendages == 2:
					if Input.is_action_pressed("left"):
						speed.x -= WALK_ACCEL
						health.temperature += 0.0003
					elif Input.is_action_pressed("right"):
						speed.x += WALK_ACCEL
						health.temperature += 0.0003
					else:
						health.temperature = move_toward(health.temperature, 30, 0.002)
					speed.x *= 0.5
				else:
					speed.x *= 0.7
					
				lwjump_buffer = 0.0
				rwjump_buffer = 0.0
			
			
			STATES.ON_AIR:
				if Input.is_action_just_released("jump") and speed.y < 0:
					speed.y *= 0.5
				if Input.is_action_just_pressed("jump") and health.broken_moving_appendages < 2:
					if  coyote_time > 0.0:
						speed.y = JUMP_ACCEL * gravity_direction.y
						coyote_time = 0.0
						
						if health.broken_moving_appendages == 1: 
							speed.y *= 0.8
						state = STATES.ON_AIR
						health.temperature += 0.002
					else:
						jump_buffer = 0.2
				jump_buffer -= delta
				coyote_time -= delta
				
				if is_on_floor():
					state = STATES.ON_GROUND
					if speed_before_collision.y > 800:
						if not Items.player_items.has("ironknees"):
							var message := "Broken Leg"
							var brkn_lgs := 0
							if health.broken_moving_appendages == 0:
								brkn_lgs = 1+randi()%2
								health.broken_moving_appendages += brkn_lgs
							elif health.broken_moving_appendages == 1:
								brkn_lgs = 1
								health.broken_moving_appendages += 1
							if brkn_lgs > 0:
								if brkn_lgs == 2:
									message = "Broken Both Legs"
								get_tree().get_nodes_in_group("HUD")[0].add_message(message)
					
					if speed_before_collision.y > 900:
						health.poked_holes += 1+randi()%3
						get_tree().get_nodes_in_group("HUD")[0].add_message("Bleeding")
				else:
					health.temperature -= 0.0003
					speed_before_collision = speed
				
				if is_on_wall():
					state = STATES.ON_WALL
				
				var haxis := 0.0
				if Input.is_action_pressed("left"):
					speed.x -= WALK_ACCEL
					haxis = -1.0
					health.temperature += 0.001
				elif Input.is_action_pressed("right"):
					speed.x += WALK_ACCEL
					haxis = 1.0
					health.temperature += 0.001
				else:
					health.temperature = move_toward(health.temperature, 30, 0.002)
				if abs(haxis)<0.5:
					speed.x *= pow(0.8, delta*60)
				elif sign(haxis)!=sign(speed.x):
					speed.x *= pow(0.9, delta*60)
				else:
					speed.x *= pow(0.75, delta*60)
				
				lwjump_buffer -= delta
				rwjump_buffer -= delta
				if Input.is_action_just_pressed("jump") and (lwjump_buffer > 0.0 or rwjump_buffer > 0.0):
					speed.y = JUMP_ACCEL * gravity_direction.y
					if health.broken_moving_appendages == 2:
						speed.y*=0.5
					state = STATES.ON_AIR
					health.temperature += 0.002
					if lwjump_buffer > 0.0:
						speed.x += 300
					elif rwjump_buffer > 0.0:
						speed.x -= 300
					lwjump_buffer = 0.2
			
			STATES.ON_WALL:
				if speed.y > 0:
					speed.y = 20
				
				if Input.is_action_just_pressed("jump"):
					speed.y = JUMP_ACCEL * gravity_direction.y
					if health.broken_moving_appendages == 2:
						speed.y*=0.5
					state = STATES.ON_AIR
					health.temperature += 0.002
					if $Left.is_colliding():
						speed.x += 300
					elif $Right.is_colliding():
						speed.x -= 300
					lwjump_buffer = 0.2
						
				if not $Left.is_colliding() and not $Right.is_colliding():
					state = STATES.ON_AIR
					
				if $Left.is_colliding():
					lwjump_buffer = 0.2
				else:
					lwjump_buffer -= delta
					
				if $Right.is_colliding():
					rwjump_buffer = 0.2
				else:
					rwjump_buffer -= delta
					
				if $Left.is_colliding() and Input.is_action_just_pressed("right"):
					state = STATES.ON_AIR
					speed.x += 50
				if $Right.is_colliding() and Input.is_action_just_pressed("left"):
					state = STATES.ON_AIR
					speed.x -= 50
				
				
				if is_on_floor():
					state = STATES.ON_GROUND
	else:
		var haxis := 0.0
		if Input.is_action_pressed("left"):
			speed.x -= WALK_ACCEL
			haxis = -1.0
			health.temperature -= 0.001
		elif Input.is_action_pressed("right"):
			speed.x += WALK_ACCEL
			haxis = 1.0
			health.temperature -= 0.001
		else:
			health.temperature = move_toward(health.temperature, 30, 0.002)
		
		var vaxis := 0.0
		if Input.is_action_pressed("up"):
			speed.y -= WALK_ACCEL
			vaxis = -1.0
			health.temperature -= 0.001
		elif Input.is_action_pressed("down"):
			speed.y += WALK_ACCEL
			vaxis = 1.0
			health.temperature -= 0.001
		else:
			health.temperature = move_toward(health.temperature, 30, 0.002)
		if abs(vaxis)<0.5:
			speed.y *= pow(0.8, delta*60)
		elif sign(vaxis)!=sign(speed.y):
			speed.y *= pow(0.9, delta*60)
		else:
			speed.y *= pow(0.75, delta*60)
		
		if abs(haxis)<0.5:
			speed.x *= pow(0.8, delta*60)
		elif sign(haxis)!=sign(speed.x):
			speed.x *= pow(0.9, delta*60)
		else:
			speed.x *= pow(0.75, delta*60)
		speed = speed.normalized()*speed.length()
	
	var spos := position
	speed = move_and_slide(speed, -gravity_direction)
	
	if Input.is_action_just_pressed("Interact2"):
		var dir := get_local_mouse_position().normalized()
		var n:RigidBody2D = preload("res://Bomb.tscn").instance()
		n.linear_velocity = dir*150
		n.position = position
		get_parent().add_child(n)
	
	$"../Camera2D".position = lerp($"../Camera2D".position, spos, 0.1)

func health_object():
	return health
