extends Character


var Cam:Camera2D
var spell_cast_pos :Vector2

var temp_stage := 0
var was_dead := false

var died_from_own_cast := false
var died_from_own_spell := false

func _ready() -> void:
	health = Items.player_health
	health.connect("was_damaged", self, "_on_damaged")
	health.connect("died", self, "health_died")
	health.connect("hole_poked", self, "send_message", ["Bleeding"])
	health.connect("full_healed", self, "send_message", ["Your flesh is renewed"])
	health.connect("effect_changed", self, "_on_effect_changes")
	health.connect("broken_leg", self, "_on_broken_leg")
	Cam = get_tree().get_nodes_in_group("Camera")[0]
	set_physics_process(false)
	set_process(false)


func _process(delta: float) -> void:
	flying = Items.player_items.has("wings")
	# Apply items
	if Items.player_items.has("gasolineblood") and not blood_is_gasoline:
		blood_is_gasoline = true
		send_message("Your insides become volatile")
	
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
	if Items.player_wands[Items.selected_wand] is Wand and Input.is_action_pressed("Interact1") and not Items.player_wands[Items.selected_wand].running and not get_tree().get_nodes_in_group("HUD")[0].block_cast:
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
	
	if (Input.is_action_just_pressed("instant_death") or (Input.is_action_pressed("instant_death_controller1") and Input.is_action_pressed("instant_death_controller2"))) and not dead and Config.instant_death_button:
		health._instakill_pressed()
	
	# Hypo and hypertermia
	if health.temperature >= -20 and health.temperature < 10 and temp_stage != -2:
		temp_stage = -2
		send_message("You feel like you're freezing")
	elif health.temperature >= 10 and health.temperature < 20 and temp_stage != -1:
		temp_stage = -1
		send_message("You feel a bit cold")
	elif health.temperature >= 20 and health.temperature < 45 and temp_stage != 0:
		temp_stage = 0
		send_message("The temperature is right")
	elif health.temperature >= 45 and health.temperature < 60 and temp_stage != 1:
		temp_stage = 1
		send_message("You feel a bit overheated")
	elif health.temperature >= 60 and health.temperature < 100 and temp_stage != 2:
		temp_stage = 2
		# Player explodes on high temperatures if their blood is nitro
		if Items.player_items.has("gasolineblood"):
			var n := preload("res://Particles/Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		send_message("You should slow down to cool off")
	elif health.temperature >= 100 and temp_stage != 3:
		temp_stage = 3
		# Player explodes on high temperatures if their blood is nitro
		if Items.player_items.has("gasolineblood"):
			var n := preload("res://Particles/Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		send_message("Your insides feel like they're melting")
	
	if dead and not was_dead:
		if health.cause_of_death != health.DEATHS.BLED and health.cause_of_death != -1:
			if health.damaged_from_side_effect:
				died_from_own_cast = true
				Config.give_achievement("fun1")
			elif health.last_damaged_by == self:
				died_from_own_spell = true
				Config.give_achievement("fun2")
		elif health.cause_of_death != -1:
			if health.bleeding_from_side_effect:
				died_from_own_cast = true
				Config.give_achievement("fun1")
			elif health.bleeding_by == self:
				died_from_own_spell = true
				Config.give_achievement("fun2")
		was_dead = true


func _physics_process(delta: float) -> void:
	$Fire.visible = health.effects.has("onfire")
	looking_at = get_local_mouse_position()
	wand = Items.player_wands[Items.selected_wand]
	inputs = {
		"left":Input.is_action_pressed("left"),
		"right":Input.is_action_pressed("right"),
		"up":Input.is_action_pressed("up"),
		"down":Input.is_action_pressed("down"),
		"jump":Input.is_action_pressed("jump"),
	}
	if Input.is_action_just_pressed("seal_blood") and health.poked_holes > 0 and Items.cloth_scraps > 0:
		health.poked_holes -= 1
		Items.cloth_scraps -= 1
	process_movement(delta)
	handle_wand_sprite($WandRender)
	animation_info($Player)
	$CastDirection.cast_to = get_local_mouse_position().normalized()*30
	if $CastDirection.is_colliding():
		spell_cast_pos = $CastDirection.get_collision_point() - position
	else:
		spell_cast_pos = $CastDirection.cast_to
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
	Cam.position = lerp(Cam.position, position, 0.1)
	
	# The wounds can cicatrize on their own
	# Bandaids help
	if health.poked_holes > 0:
		var plus := 0.0008 * 0.0008*Items.player_items.count("bandaid")
		if randf() < 0.0005 + plus:
			health.poked_holes -= 1
			if health.poked_holes < 0:
				health.poked_holes = 0
			if health.poked_holes == 0:
				send_message("Bleeding has ceased")


func _on_generated_world() -> void:
	set_physics_process(true)
	set_process(true)


func cast_from():
	return spell_cast_pos + position


func send_message(message):
	get_tree().get_nodes_in_group("HUD")[0].add_message(message)


func _on_effect_changes(effect:String, added:bool) -> void:
	match effect:
		"onfire":
			if added:
				send_message("You are on fire")
			else:
				send_message("You are not on fire")


func _on_broken_leg(amount:int) -> void:
	match amount:
		1:
			send_message("Broken leg")
			if Items.player_items.has("gasolineblood"):
				var n := preload("res://Particles/Explosion.tscn").instance()
				n.position = position
				get_parent().add_child(n)
		2:
			send_message("Broken both legs")
			if Items.player_items.has("gasolineblood"):
				var n := preload("res://Particles/Explosion.tscn").instance()
				n.position = position
				get_parent().add_child(n)


func _on_DamageTimer_timeout() -> void:
	modulate = Color("#ffffff")
