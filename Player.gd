extends KinematicBody2D

signal player_died

enum STATES {
	ON_GROUND,
	ON_AIR,
	ON_WALL,
	DEAD
}

const WALK_ACCEL := 70.0
const JUMP_ACCEL := -370.0

var Cam :Camera2D

var gravity_accel := 15.0
var gravity_direction := Vector2(0, 1)

var speed := Vector2()

var state :int = STATES.ON_AIR

var speed_before_collision := Vector2(0, 0)
var jump_buffer := 0.0
var coyote_time := 0.0
var lwcoyote_time := 0.0
var rwcoyote_time := 0.0

var health :Flesh = Items.player_health

var Map :TileMap

var temp_stage := 0

var blood_is_gasoline := false

var dead := false


func _ready():
	Map = get_tree().get_nodes_in_group("World")[0]
	health.connect("hole_poked", self, "message_send", ["Bleeding"])
	health.connect("full_healed", self, "message_send", ["Your flesh is renewed"])
	health.is_players = true
	Cam = get_tree().get_nodes_in_group("Camera")[0]
	set_process(false)
	set_physics_process(false)
	$"../Camera2D".position = lerp($"../Camera2D".position, position, 0.1)


func _process(delta):
	if health.poked_holes > 0:
		if Input.is_action_just_pressed("seal_blood"):
			if randf()<0.92:
				health.poked_holes -= 1
			if health.poked_holes < 0:
				health.poked_holes = 0
			if health.poked_holes == 0:
				message_send("Wound has been covered, bleeding has stopped")
	
		if randf() < 0.002:
			health.poked_holes -= 1
			if health.poked_holes < 0:
				health.poked_holes = 0
			if health.poked_holes == 0:
				message_send("Bleeding has ceased")
	
	
	# Hypo and hypertermia
	if health.temperature >= -20 and health.temperature < 10 and temp_stage != -2:
		temp_stage = -2
		message_send("You feel like you're freezing")
	elif health.temperature >= 10 and health.temperature < 20 and temp_stage != -1:
		temp_stage = -1
		message_send("You feel a bit cold")
	elif health.temperature >= 20 and health.temperature < 45 and temp_stage != 0:
		temp_stage = 0
		message_send("The temperature is right")
	elif health.temperature >= 45 and health.temperature < 60 and temp_stage != 1:
		temp_stage = 1
		message_send("You feel a bit overheated")
	elif health.temperature >= 60 and health.temperature < 100 and temp_stage != 2:
		temp_stage = 2
		if Items.player_items.has("gasolineblood"):
			var n := preload("res://Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		message_send("You should slow down to cool off")
	elif health.temperature >= 100 and temp_stage != 3:
		temp_stage = 3
		if Items.player_items.has("gasolineblood"):
			var n := preload("res://Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		message_send("Your insides feel like they're melting")
	
	# Control the camera with the mouse
	var coffset := get_local_mouse_position()/4.0
	Cam.offset += (coffset-Cam.offset)/5.0
	
	# Death
	if (health.temperature > 145 or health.soul <= 0.0 or health.blood <= 0.0 or Input.is_key_pressed(KEY_G)) and not dead:
		emit_signal("player_died")
		state = STATES.DEAD
		dead = true
	
	# Apply items
	if Items.player_items.has("gasolineblood") and not blood_is_gasoline:
		blood_is_gasoline = true
		message_send("Your insides become volatile")
	
	if Items.player_items.has("thickblood"):
		Items.player_items.erase("thickblood")
		health.max_blood *= 2.0
		health.blood *= 2.0
		
	if Items.player_items.has("heal"):
		Items.player_items.erase("heal")
		health.full_heal()
		
	if Items.player_items.has("scraps"):
		Items.player_items.erase("scraps")
		Items.cloth_scraps += 1
	
	# Control wand HUD
	if Items.player_wands[Items.selected_wand] is Wand and Input.is_action_just_pressed("Interact1") and not Items.player_wands[Items.selected_wand].running and not get_tree().get_nodes_in_group("HUD")[0].block_cast:
		Items.player_wands[Items.selected_wand].running = true
	
	if Input.is_action_just_released("scrollup"):
		Items.selected_wand -= 1
		if Items.selected_wand < 0:
			Items.selected_wand = 5
		
	elif Input.is_action_just_released("scrolldown"):
		Items.selected_wand = (Items.selected_wand + 1) % 6
	
	if Input.is_action_just_pressed("hotbar1"):
		Items.selected_wand = 0
	elif Input.is_action_just_pressed("hotbar2"):
		Items.selected_wand = 1
	elif Input.is_action_just_pressed("hotbar3"):
		Items.selected_wand = 2
	elif Input.is_action_just_pressed("hotbar4"):
		Items.selected_wand = 3
	elif Input.is_action_just_pressed("hotbar5"):
		Items.selected_wand = 4
	elif Input.is_action_just_pressed("hotbar6"):
		Items.selected_wand = 5


func _physics_process(delta):
	# Bleed
	health.blood -= health.poked_holes * (0.5+randf())*0.0005
	# Platforms
	set_collision_mask_bit(2, not Input.is_key_pressed(KEY_S))
	
	# Player is alive
	if not dead:
		if not Items.player_items.has("wings"):
			match state:
				STATES.ON_GROUND:
					if abs(speed.x) < 10.0 or randf()<0.002:
						if health.broken_moving_appendages != 2:
							if health.temperature > 30.02:
								$Player.play("panting")
							else:
								$Player.play("default")
						else:
							$Player.play("crawl")
					elif speed.x > 0.0:
						if health.broken_moving_appendages != 2:
							if get_local_mouse_position().x > 0:
								$Player.play("run")
							else:
								$Player.play("run", true)
						else:
							if get_local_mouse_position().x > 0:
								$Player.play("crawling")
							else:
								$Player.play("crawling", true)
					else:
						if health.broken_moving_appendages != 2:
							if get_local_mouse_position().x < 0:
								$Player.play("run")
							else:
								$Player.play("run", true)
						else:
							if get_local_mouse_position().x > 0:
								$Player.play("crawling")
							else:
								$Player.play("crawling", true)
						
					if get_local_mouse_position().x > 0:
						$Player.scale.x = 1
					else:
						$Player.scale.x = -1
				STATES.ON_AIR:
					if health.broken_moving_appendages != 2:
						if sign(speed.y) > 0:
							$Player.play("down")
						else:
							$Player.play("up")
						if get_local_mouse_position().x > 0:
							$Player.scale.x = 1
						else:
							$Player.scale.x = -1
				STATES.ON_WALL:
					var kin := move_and_collide(Vector2(2, 0), true, true, true)
					if kin != null:
						$Player.scale.x = 1
						if get_local_mouse_position().x < 0:
							if health.broken_moving_appendages == 0:
								$Player.play("slide")
							else:
								$Player.play("oneleg_slide")
						else:
							if health.broken_moving_appendages == 0:
								$Player.play("slide2")
							else:
								$Player.play("oneleg_slide2")
					else:
						$Player.scale.x = -1
						if get_local_mouse_position().x > 0:
							if health.broken_moving_appendages == 0:
								$Player.play("slide")
							else:
								$Player.play("oneleg_slide")
						else:
							if health.broken_moving_appendages == 0:
								$Player.play("slide2")
							else:
								$Player.play("oneleg_slide2")
		else:
			if get_local_mouse_position().x > 0:
				$Player.scale.x = 1
			else:
				$Player.scale.x = -1
			$Player.play("default")
		# Player can't fly
		if not Items.player_items.has("wings"):
			# Gravity
			speed.y += gravity_accel * gravity_direction.y
			match state:
				STATES.ON_GROUND:
					coyote_time = 0.12
					if not is_on_floor():
						state = STATES.ON_AIR
					jump()
					jump_buffer = 0.0
					
					if health.broken_moving_appendages == 0:
						move_damp(delta)
					elif health.broken_moving_appendages == 2:
						move_nondamp()
					else:
						speed.x *= 0.7
						
					lwcoyote_time = 0.0
					rwcoyote_time = 0.0
				
				
				STATES.ON_AIR:
					# Control jump height
					if Input.is_action_just_released("jump") and speed.y < 0:
						speed.y *= 0.5
					if  coyote_time > 0.0:
						jump()
					elif Input.is_action_just_pressed("jump") and health.broken_moving_appendages < 2:
						jump_buffer = 0.2
					jump_buffer -= delta
					coyote_time -= delta
					
					if is_on_floor():
						state = STATES.ON_GROUND
						# Break legs
						if speed_before_collision.y > 800:
							if Items.player_items.has("gasolineblood"):
								var n := preload("res://Explosion.tscn").instance()
								n.position = position
								get_parent().add_child(n)
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
							
						# Bleed
						if speed_before_collision.y > 900:
							health.poked_holes += 1+randi()%3
							get_tree().get_nodes_in_group("HUD")[0].add_message("Bleeding")
					else:
						health.temperature -= 0.0003
						speed_before_collision = speed
					
					if is_on_wall():
						state = STATES.ON_WALL
						if abs(speed_before_collision.x) > 1000:
							dead = true
							emit_signal("player_died")
					
					if is_on_ceiling() and speed_before_collision.y < -800:
						dead = true
						emit_signal("player_died")
					
					move_damp(delta)
					
					lwcoyote_time -= delta
					rwcoyote_time -= delta
					wall_jump()
				
				STATES.ON_WALL:
					if speed.y > 0:
						speed.y = lerp(speed.y, 60, 0.3)
					jump_buffer -= delta
					wall_jump()
					if not $Left.is_colliding() and not $Right.is_colliding():
						state = STATES.ON_AIR
						
					if $Left.is_colliding():
						lwcoyote_time = 0.2
					else:
						lwcoyote_time -= delta
						
					if $Right.is_colliding():
						rwcoyote_time = 0.2
					else:
						rwcoyote_time -= delta
						
					if $Left.is_colliding() and Input.is_action_just_pressed("right"):
						state = STATES.ON_AIR
						speed.x += 50
					if $Right.is_colliding() and Input.is_action_just_pressed("left"):
						state = STATES.ON_AIR
						speed.x -= 50
					
					
					if is_on_floor():
						state = STATES.ON_GROUND
		else: # Player is flying
			speed.y += gravity_accel * gravity_direction.y
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
	else: # Player is dead
		speed.x *= 0.75
	
	speed = move_and_slide(speed, -gravity_direction)
	if randf() < (1.0-health.soul)/15.0:
		move_and_collide(Vector2(-1+randf()*2, -1+randf()*2)*((1.0-health.soul/10.0))*5.0)
	
	
	$"../Camera2D".position = lerp($"../Camera2D".position, position, 0.1)


func health_object():
	return health


func message_send(msg):
	get_tree().get_nodes_in_group("HUD")[0].add_message(msg)


func _on_generated_world():
	set_process(true)
	set_physics_process(true)


func jump():
	if (Input.is_action_just_pressed("jump") or jump_buffer > 0.0) and health.broken_moving_appendages < 2:
		speed.y += JUMP_ACCEL * gravity_direction.y
		coyote_time = 0.0
		if health.broken_moving_appendages == 1: 
			speed.y *= 0.6+randf()*0.4
		state = STATES.ON_AIR
		health.temperature += 0.002

func move_damp(delta):
	var haxis := 0.0
	if Input.is_action_pressed("left"):
		speed.x -= WALK_ACCEL
		haxis = -1.0
		health.temperature += 0.002
	elif Input.is_action_pressed("right"):
		speed.x += WALK_ACCEL
		haxis = 1.0
		health.temperature += 0.002
	health.temperature = move_toward(health.temperature, 30, 0.001)
	if abs(haxis)<0.5:
		speed.x *= pow(0.8, delta*60)
	elif sign(haxis)!=sign(speed.x):
		speed.x *= pow(0.9, delta*60)
	else:
		speed.x *= pow(0.75, delta*60)

func move_nondamp():
	if Input.is_action_pressed("left"):
		speed.x -= WALK_ACCEL
		health.temperature += 0.0003
	elif Input.is_action_pressed("right"):
		speed.x += WALK_ACCEL
		health.temperature += 0.0003
	else:
		health.temperature = move_toward(health.temperature, 30, 0.002)
	speed.x *= 0.5

func wall_jump():
	if (Input.is_action_just_pressed("jump") or jump_buffer > 0.0) and (lwcoyote_time > 0.0 or rwcoyote_time > 0.0):
		speed.y = JUMP_ACCEL * gravity_direction.y
		jump_buffer = 0.0
		if health.broken_moving_appendages == 2:
			speed.y*=0.5
		state = STATES.ON_AIR
		health.temperature += 0.002
		if lwcoyote_time > 0.0:
			speed.x += 300
			lwcoyote_time = 0.0
		elif rwcoyote_time > 0.0:
			speed.x -= 300
			rwcoyote_time = 0.0

func looking_at() -> Vector2:
	return get_local_mouse_position() + position
