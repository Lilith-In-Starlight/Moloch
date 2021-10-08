extends KinematicBody2D

# Sent when the player dies
signal player_died

enum STATES {
	ON_GROUND,
	ON_AIR,
	ON_WALL,
	ON_POLE,
	DEAD
}

# Speed constants
const WALK_ACCEL := 70.0
const JUMP_ACCEL := -370.0

# Camera node
var Cam :Camera2D

# Gravity vars
var gravity_accel := 15.0
var gravity_direction := Vector2(0, 1)

onready var WandRender := $WandRender

var speed := Vector2()

# State machine
var state :int = STATES.ON_AIR

# Input improvements
var speed_before_collision := Vector2(0, 0)
var jump_buffer := 0.0
var coyote_time := 0.0
var lwcoyote_time := 0.0
var rwcoyote_time := 0.0

# Flesh
var health :Flesh = Items.player_health

var Map :TileMap

# The stage of temperature, for temperature messages
var temp_stage := 0

var blood_is_gasoline := false

var dead := false

var spell_cast_pos := Vector2(0, 0)

var can_climb_pole := false
var pole_pos := 0.0
var pole_side := false

var aim := Vector2(0, 0)


func _ready():
	# Setup
	Items.Player = get_tree().get_nodes_in_group("Player")[0]
	Map = get_tree().get_nodes_in_group("World")[0]
	health.connect("was_damaged",self, "_on_damaged")
	health.connect("hole_poked", self, "message_send", ["Bleeding"])
	health.connect("full_healed", self, "message_send", ["Your flesh is renewed"])
	health.connect("died", self, "health_died")
	health.is_players = true
	Cam = get_tree().get_nodes_in_group("Camera")[0]
	# The processes are off until the game starts
	set_process(false)
	set_physics_process(false)
	# Move the Camera position to the player
	$"../Camera2D".position = lerp($"../Camera2D".position, position, 0.1)


func _process(delta):
	# If the player is bleeding
	if health.poked_holes > 0:
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
		
		# Heal the player with cloth scraps
		if Input.is_action_just_pressed("seal_blood") and Items.cloth_scraps > 0:
			Items.cloth_scraps -= 1
			if randf()<0.92:
				health.poked_holes -= 1
			if health.poked_holes < 0:
				health.poked_holes = 0
			if health.poked_holes == 0:
				message_send("Wound has been covered, bleeding has stopped")
		
		# The wounds can cicatrize on their own
		# Bandaids help
		var plus := 0.0008 * 0.0008*Items.player_items.count("bandaid")
		if randf() < 0.0005 + plus:
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
		# Player explodes on high temperatures if their blood is nitro
		if Items.player_items.has("gasolineblood"):
			var n := preload("res://Particles/Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		message_send("You should slow down to cool off")
	elif health.temperature >= 100 and temp_stage != 3:
		temp_stage = 3
		# Player explodes on high temperatures if their blood is nitro
		if Items.player_items.has("gasolineblood"):
			var n := preload("res://Particles/Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		message_send("Your insides feel like they're melting")
	
	# Controller aim
	var mouse_pos := get_viewport().get_mouse_position()
	var xproportion := get_viewport().size.x/800.0
	var yproportion := get_viewport().size.y/450.0
	var axis := Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY))
	axis = axis.normalized()*axis.length_squared() * Config.joystick_sensitivity
	var dx := abs(axis.x * xproportion)
	var dy := abs(axis.y * yproportion)
	if Input.is_action_pressed("aim_up"):
		if mouse_pos.y - dy > 0:
			get_viewport().warp_mouse(mouse_pos - Vector2(0, dy))
			mouse_pos -= Vector2(0, dy)
		else:
			get_viewport().warp_mouse(Vector2(mouse_pos.x, 1))
			mouse_pos.y = 1
	elif Input.is_action_pressed("aim_down"):
		if mouse_pos.y + dy < get_viewport().size.y:
			get_viewport().warp_mouse(mouse_pos + Vector2(0, dy))
			mouse_pos += Vector2(0, dy)
		else:
			get_viewport().warp_mouse(Vector2(mouse_pos.x, get_viewport().size.y-1))
			mouse_pos.y = get_viewport().size.y-1
	
	if Input.is_action_pressed("aim_left"):
		if mouse_pos.x - dx > 0:
			get_viewport().warp_mouse(mouse_pos - Vector2(dx, 0))
			mouse_pos -= Vector2(dx, 0)
		else:
			get_viewport().warp_mouse(Vector2(1, mouse_pos.y))
			mouse_pos.x = 0
	elif Input.is_action_pressed("aim_right"):
		if mouse_pos.x + dx < get_viewport().size.x:
			get_viewport().warp_mouse(mouse_pos + Vector2(dx, 0))
			mouse_pos += Vector2(dx, 0)
		else:
			get_viewport().warp_mouse(Vector2(get_viewport().size.x-1, mouse_pos.y))
			mouse_pos.x = get_viewport().size.x-1
	
	# Control the camera with the mouse
	var coffset := get_local_mouse_position()/2.5
	Cam.offset += (coffset-Cam.offset)/5.0
	
	# Death
	# To avoid ruining runs for controller users, it takes two buttons to instantly die
	if (Input.is_action_just_pressed("instant_death") or (Input.is_action_pressed("instant_death_controller1") and Input.is_action_pressed("instant_death_controller2"))) and not dead and Config.instant_death_button:
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
		
	if Items.player_items.has("soulfulpill"):
		Items.player_items.erase("soulfulpill")
		health.soul += 0.3+randf()*0.2
		
	if Items.player_items.has("icecube"):
		Items.player_items.erase("icecube")
		health.temp_change(-5.0)
		
	if Items.player_items.has("heatadapt"):
		Items.player_items.erase("heatadapt")
		health.death_hypertemperature += 20
		
	if Items.player_items.has("dissipator"):
		Items.player_items.erase("dissipator")
		health.temp_regulation += 0.005
	
	for i in Items.player_items.count("gluestone"):
		if get_tree().get_nodes_in_group("Gluestone").size() <= i:
			var new_gluestone := preload("res://Companions/Gluestone.tscn").instance()
			new_gluestone.position = position
			get_parent().add_child(new_gluestone)
	
	for i in Items.player_items.count("egg"):
		if get_tree().get_nodes_in_group("Egg").size() <= i:
			var new_gluestone := preload("res://Companions/FloatingEgg.tscn").instance()
			new_gluestone.position = position
			get_parent().add_child(new_gluestone)
	
	# Companions
	for i in Items.companions.size():
		if get_tree().get_nodes_in_group("Companion").size() <= i:
			var new_gluestone := preload("res://Companions/Companion.tscn").instance()
			new_gluestone.position = position
			new_gluestone.health = Items.companions[i][0]
			new_gluestone.wand = Items.companions[i][1]
			get_parent().add_child(new_gluestone)
	
	# Control wand HUD
	if Items.player_wands[Items.selected_wand] is Wand and Input.is_action_just_pressed("Interact1") and not Items.player_wands[Items.selected_wand].running and not get_tree().get_nodes_in_group("HUD")[0].block_cast:
		Items.player_wands[Items.selected_wand].shuffle()
		Items.player_wands[Items.selected_wand].run(self)
	
	if not Config.last_input_was_controller:
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
	
	# Render the wand the player has
	WandRender.visible = Items.player_wands[Items.selected_wand] != null
	WandRender.render_wand(Items.player_wands[Items.selected_wand], false)
	WandRender.position += (get_local_mouse_position().normalized()*22 - WandRender.position)/3.0
	WandRender.rotation = lerp_angle(WandRender.rotation, get_local_mouse_position().angle() + PI/4.0, 1/3.0)

func _physics_process(delta):
	$CastDirection.enabled = Items.player_wands[Items.selected_wand] != null
	$CastDirection.cast_to = get_local_mouse_position().normalized()*30
	if $CastDirection.is_colliding():
		spell_cast_pos = $CastDirection.get_collision_point() - position
	else:
		spell_cast_pos = $CastDirection.cast_to
	health.process_health()
	# Platforms
	set_collision_mask_bit(2, not Input.is_action_pressed("down"))
	
	# Player is alive
	if not dead:
		# Not flying
		if not Items.player_items.has("wings"):
			# Animations
			match state:
				# Touching the ground
				STATES.ON_GROUND:
					# Idle animation
					if abs(speed.x) < 10.0 or randf()<0.002:
						# Player has one or two legs
						if health.broken_moving_appendages != 2:
							if health.temperature > 30.02:
								$Player.play("panting")
							else:
								$Player.play("default")
						else:
							# Playyer has no legs
							$Player.play("crawl")
					elif speed.x > 0.0: # Moving
						# Has both legs or one leg
						if health.broken_moving_appendages != 2:
							$Player.scale.x = 1
							if get_local_mouse_position().x > 0:
								$Player.play("run")
							else:
								$Player.play("run_lookback")
						else: # Has no legs
							if get_local_mouse_position().x > 0:
								$Player.play("crawling")
							else:
								$Player.play("crawling", true)
								
							# Where is the player looking at
							if get_local_mouse_position().x > 0:
								$Player.scale.x = 1
							else:
								$Player.scale.x = -1
					else:
						# Has both legs
						if health.broken_moving_appendages != 2:
							$Player.scale.x = -1
							if get_local_mouse_position().x > 0:
								$Player.play("run_lookback")
							else:
								$Player.play("run")
						else: # Has no legs
							if get_local_mouse_position().x > 0:
								$Player.play("crawling")
							else:
								$Player.play("crawling", true)
						
							# Where is the player looking at
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
					# Detect what wall is being collided with
					# Check for left
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
					else: # Isn't left, must be right
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
				STATES.ON_POLE:
					$Player.play("slide")
					if pole_pos < position.x:
						$Player.scale.x = -1
					else:
						$Player.scale.x = 1
		else: # Is flying
			if get_local_mouse_position().x > 0:
				$Player.scale.x = 1
			else:
				$Player.scale.x = -1
			$Player.play("default")
		
		# Physics
		# Player can't fly
		if not Items.player_items.has("wings"):
			# Gravity
			if not state == STATES.ON_POLE:
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
					
					# If the player touches the ground, no walljump
					lwcoyote_time = 0.0
					rwcoyote_time = 0.0
				
				
				STATES.ON_AIR:
					# Control jump height
					if Input.is_action_just_released("jump") and speed.y < 0:
						speed.y *= 0.5
					if  coyote_time > 0.0:
						jump()
					elif Input.is_action_just_pressed("jump"):
						jump_buffer = 0.2
					
					if (Input.is_action_pressed("up") or Input.is_action_pressed("down")) and can_climb_pole:
						if pole_pos > position.x:
							position.x = pole_pos + 2
						else:
							position.x = pole_pos - 2
						state = STATES.ON_POLE
					
					jump_buffer -= delta
					coyote_time -= delta
					
					
					if is_on_floor():
						state = STATES.ON_GROUND
						# Break legs
						if speed_before_collision.y > 800:
							if Items.player_items.has("gasolineblood"):
								var n := preload("res://Particles/Explosion.tscn").instance()
								n.position = position
								get_parent().add_child(n)
							
							# If the player's knees aren't iron
							if not Items.player_items.has("ironknees"):
								var message := "Broken Leg"
								var brkn_lgs := 0
								# If the player has broken no legs
								if health.broken_moving_appendages == 0:
									brkn_lgs = 1+randi()%2 # Might break both
									health.broken_moving_appendages += brkn_lgs
								# If the player has only one broken leg
								elif health.broken_moving_appendages == 1:
									brkn_lgs = 1 # Can only break one
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
						# Break ribs
						if abs(speed_before_collision.x) > 1000:
							dead = true
							emit_signal("player_died")
					
					# Break skull
					if is_on_ceiling() and speed_before_collision.y < -800:
						dead = true
						emit_signal("player_died")
					
					move_damp(delta)
					
					lwcoyote_time -= delta
					rwcoyote_time -= delta
					wall_jump()
				
				STATES.ON_WALL:
					# Slide on wall
					if speed.y > 0:
						speed.y = lerp(speed.y, 60, 0.3)
					
					jump_buffer -= delta
					wall_jump()
					
					# Check for wall direction
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
				
				STATES.ON_POLE:
					coyote_time -= delta
					if Input.is_action_pressed("up"):
						speed.y = lerp(speed.y, -90, 0.3)
					elif Input.is_action_pressed("down"):
						speed.y = lerp(speed.y, 90, 0.3)
					else:
						speed.y = lerp(speed.y, 10, 0.3)
					
					if Input.is_action_just_pressed("jump") or jump_buffer > 0.0:
						jump_buffer = 0.2
						coyote_time = 0.22
						can_climb_pole = false
						if Input.is_action_just_pressed("right"):
							speed.x = lerp(speed.x, 50, 0.6)
						if Input.is_action_just_pressed("left"):
							speed.x = lerp(speed.x, -50, 0.6)
					else:
						speed.x = 0
					if is_on_floor() or not can_climb_pole:
						state = STATES.ON_GROUND
		else: # Player is flying
			speed.y += gravity_accel * gravity_direction.y
			# Horizontal movement
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
				health.temperature = move_toward(health.temperature, 30, health.temp_regulation)
			
			# Vertical movement
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
				health.temperature = move_toward(health.temperature, 30, health.temp_regulation)
			
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
			speed = speed.normalized()*speed.length()
	
	else: # Player is dead
		speed.x *= 0.75
	
	speed = move_and_slide(speed, -gravity_direction)
	
	# If the soul is unstable, the player jitters
	if randf() < (health.needed_soul-health.soul)/15.0:
		var n := preload("res://Particles/Soul.tscn").instance()
		n.position = position
		get_parent().add_child(n)
		move_and_collide(Vector2(-1+randf()*2, -1+randf()*2)*((health.needed_soul-health.soul/10.0))*5.0)
	
	# Move the camera
	$"../Camera2D".position = lerp($"../Camera2D".position, position, 0.1)


func health_object():
	return health


func message_send(msg):
	get_tree().get_nodes_in_group("HUD")[0].add_message(msg)


# The world is done generating
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
	else:
		health.temperature = move_toward(health.temperature, 30, health.temp_regulation)
	health.temperature = move_toward(health.temperature, 30, health.temp_regulation)
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
		health.temperature = move_toward(health.temperature, 30, health.temp_regulation)
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


func cast_from() -> Vector2:
	return spell_cast_pos + position


func enable_pole(pos):
	can_climb_pole = true
	pole_pos = pos


func disable_pole():
	can_climb_pole = false


func health_died():
	if not dead:
		emit_signal("player_died")
		state = STATES.DEAD
		dead = true


func _on_DamageTimer_timeout() -> void:
	modulate = Color("#ffffff")


func _on_damaged(damage_type:String) -> void:
	Items.damage_visuals(self, $DamageTimer, damage_type)
