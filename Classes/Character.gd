extends KinematicBody2D

class_name Character

signal entity_died

const COYOTE_TIME := 0.2
const INPUT_BUFFER := 0.1

enum STATES {
	GROUND,
	AIR,
	WALL,
	POLE,
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

var pole_position := 0.0
var can_climb_pole := false

var jump_height_control := false

var looking_at := Vector2(0, 0)

var wand :Wand

var last_speed_before_collision := Vector2(0, 0)

var blood_is_gasoline := false

var dead := false
var flying := false


func _ready() -> void:
	health.connect("was_damaged",self, "_on_damaged")
	health.connect("died", self, "health_died")


func process_movement(delta:float) -> void:
	health.process_health(delta, speed)
	bleed()
	d_unit = delta * 60.0
	speed.y += fall_speed * d_unit
	set_collision_mask_bit(2, not input_pressed("down"))
	if not dead:
		if not flying:
			match state:
				STATES.AIR:
					walking()
					jumping()
					wall_jumping()
					
					if is_on_floor():
						state = STATES.GROUND
						if last_speed_before_collision.y > 800:
							health.break_legs()
					
					if is_on_wall():
						state = STATES.WALL
						
					if not input_pressed("jump") and jump_height_control:
						speed.y *= 0.5
						jump_height_control = false
					
					if can_climb_pole:
						if input_pressed("up") or input_pressed("down"):
							state = STATES.POLE
				
				STATES.GROUND:
					jump_height_control = true
					ground_coyote_time = COYOTE_TIME
					
					walking()
					jumping()
					
					if not is_on_floor():
						state = STATES.AIR
				
				STATES.WALL:
					jump_height_control = true
					speed.y += fall_speed * 0.02 * -sign(speed.y) * d_unit
					speed.y *= 0.85 * d_unit
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
					
				
				STATES.POLE:
					jump_height_control = true
					ground_coyote_time = COYOTE_TIME
					speed.y += fall_speed * 0.01 * -sign(speed.y) * d_unit
					speed.y *= 0.9
					speed.x *= 0.1
					if input_pressed("up"):
						speed.y -= walk_accel * d_unit
					elif input_pressed("down"):
						speed.y += walk_accel * d_unit
					speed.y *= 0.7 * d_unit
					var jump_x := 0
					if input_pressed("left"):
						position.x = pole_position - 4
						jump_x = -50
					elif input_pressed("right"):
						position.x = pole_position + 4
						jump_x = 50
					jumping(jump_x, jump_force * 0.9)
					
					if not can_climb_pole:
						state = STATES.AIR
		else:
			speed.y += fall_speed * d_unit
			# Horizontal movement
			var haxis := 0.0
			if Input.is_action_pressed("left"):
				speed.x -= walk_accel * d_unit
				haxis = -1.0
			elif Input.is_action_pressed("right"):
				speed.x += walk_accel * d_unit
				haxis = 1.0
			
			# Vertical movement
			var vaxis := 0.0
			if Input.is_action_pressed("up"):
				speed.y -= walk_accel * d_unit * 1.5
				vaxis = -1.0
			elif Input.is_action_pressed("down"):
				speed.y += walk_accel * d_unit
				vaxis = 1.0
			
			# Damping
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
	
	
	ground_coyote_time -= delta
	ground_jump_buffer -= delta
	rwall_coyote_time -= delta
	lwall_coyote_time -= delta
	wall_jump_buffer -= delta
	last_frame_inputs = inputs.duplicate()
	
	
	if randf() < (health.needed_soul-health.soul)/15.0:
		var n := preload("res://Particles/Soul.tscn").instance()
		n.position = position
		get_parent().add_child(n)
		move_and_collide(Vector2(-1+randf()*2, -1+randf()*2)*((health.needed_soul-health.soul/10.0))*10.0)

	last_speed_before_collision = speed
	speed = move_and_slide(speed, Vector2(0, -1))

func bleed() -> void:
	# If the player is bleeding
	if health.poked_holes > 0 and health.blood > 0.01:
		# Emit blood particles 
		for i in min(health.poked_holes, 12):
			if randf()>0.9:
				var n :RigidBody2D = preload("res://Particles/Blood.tscn").instance()
				n.position = position + Vector2(0, 6)
				n.linear_velocity = Vector2(-200 + randf()*400, -80 + randf()*120)
				if not blood_is_gasoline:
					n.modulate = ColorN("red")
				else:
					n.modulate = ColorN("green")
				get_parent().add_child(n)


func animation_info(sprite:AnimatedSprite) -> void:
	if not dead:
		if not flying:
			# Animations
			match state:
				# Touching the ground
				STATES.GROUND:
					# Idle animation
					if abs(speed.x) < 10.0 or randf()<0.002:
						# Player has one or two legs
						if health.broken_moving_appendages != 2:
							if health.temperature > 30.02:
								sprite.play("panting")
							else:
								sprite.play("default")
						else:
							# Playyer has no legs
							sprite.play("crawl")
					elif speed.x > 0.0: # Moving
						# Has both legs or one leg
						if health.broken_moving_appendages != 2:
							sprite.scale.x = 1
							if looking_at.x > 0:
								sprite.play("run")
							else:
								sprite.play("run_lookback")
						else: # Has no legs
							if looking_at.x > 0:
								sprite.play("crawling")
							else:
								sprite.play("crawling", true)
								
							# Where is the player looking at
							if looking_at.x > 0:
								sprite.scale.x = 1
							else:
								sprite.scale.x = -1
					else:
						# Has both legs
						if health.broken_moving_appendages != 2:
							sprite.scale.x = -1
							if looking_at.x > 0:
								sprite.play("run_lookback")
							else:
								sprite.play("run")
						else: # Has no legs
							if looking_at.x > 0:
								sprite.play("crawling")
							else:
								sprite.play("crawling", true)
						
							# Where is the player looking at
							if looking_at.x > 0:
								sprite.scale.x = 1
							else:
								sprite.scale.x = -1
				STATES.AIR:
					if health.broken_moving_appendages != 2:
						if sign(speed.y) > 0:
							sprite.play("down")
						else:
							sprite.play("up")
						if looking_at.x > 0:
							sprite.scale.x = 1
						else:
							sprite.scale.x = -1
				STATES.WALL:
					# Detect what wall is being collided with
					# Check for left
					var kin := move_and_collide(Vector2(2, 0), true, true, true)
					if kin != null:
						sprite.scale.x = 1
						if looking_at.x < 0:
							if health.broken_moving_appendages == 0:
								sprite.play("slide")
							else:
								sprite.play("oneleg_slide")
						else:
							if health.broken_moving_appendages == 0:
								sprite.play("slide2")
							else:
								sprite.play("oneleg_slide2")
					else: # Isn't left, must be right
						sprite.scale.x = -1
						if looking_at.x > 0:
							if health.broken_moving_appendages == 0:
								sprite.play("slide")
							else:
								sprite.play("oneleg_slide")
						else:
							if health.broken_moving_appendages == 0:
								sprite.play("slide2")
							else:
								sprite.play("oneleg_slide2")
				STATES.POLE:
					sprite.play("slide")
					if pole_position < position.x:
						sprite.scale.x = -1
					else:
						sprite.scale.x = 1
		else:
			if looking_at.x > 0:
				sprite.scale.x = 1
			else:
				sprite.scale.x = -1
			sprite.play("default")

func handle_wand_sprite(sprite:Node2D) -> void:
	sprite.visible = wand != null
	sprite.render_wand(wand, false)
	sprite.position += (looking_at.normalized()*22 - sprite.position)/3.0
	sprite.rotation = lerp_angle(sprite.rotation, looking_at.angle() + PI/4.0, 1/3.0)


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
		1:
			if state == STATES.AIR:
				if abs(haxis)<0.5:
					speed.x *= pow(0.8, d_unit)
				elif sign(haxis)!=sign(speed.x):
					speed.x *= pow(0.9, d_unit)
				else:
					speed.x *= pow(0.75, d_unit)
			else:
				speed.x *= 0

		2:
			if state == STATES.AIR:
				if abs(haxis)<0.5:
					speed.x *= pow(0.8, d_unit)
				elif sign(haxis)!=sign(speed.x):
					speed.x *= pow(0.9, d_unit)
				else:
					speed.x *= pow(0.75, d_unit)
			else:
				if abs(haxis)<0.5:
					speed.x *= pow(0.3, d_unit)
				elif sign(haxis)!=sign(speed.x):
					speed.x *= pow(0.3, d_unit)
				else:
					speed.x *= pow(0.3, d_unit)


func jumping(x_speed := 0.0, y_speed := jump_force):
	if health.broken_moving_appendages != health.moving_appendages:
		if input_just_pressed("jump") or ground_jump_buffer > 0.0:
			if ground_coyote_time > 0.0:
				speed.y = y_speed
				speed.x += x_speed
				ground_coyote_time = 0.0
				ground_jump_buffer = 0.0
				if state == STATES.POLE:
					can_climb_pole = false
				state = STATES.AIR
			elif input_just_pressed("jump"):
				ground_coyote_time = 0.0
				ground_jump_buffer = INPUT_BUFFER


func wall_jumping():
	if input_just_pressed("jump") or wall_jump_buffer > 0.0:
		if lwall_coyote_time > 0.0:
			speed.y = jump_force*0.9
			speed.x = -jump_force
			lwall_coyote_time = 0.0
			rwall_coyote_time = 0.0
			wall_jump_buffer = 0.0
			state = STATES.AIR
		elif rwall_coyote_time > 0.0:
			speed.y = jump_force*0.9
			speed.x = jump_force
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


func enable_pole(pos):
	can_climb_pole = true
	pole_position = pos


func disable_pole():
	can_climb_pole = false


func looking_at():
	return looking_at + position


func health_died():
	if not dead:
		emit_signal("entity_died")
		dead = true


func _on_damaged(damage_type:String) -> void:
	Items.damage_visuals(self, $DamageTimer, damage_type)
