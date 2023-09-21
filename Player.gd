extends Character


var spell_cast_pos :Vector2

var temp_stage := 0
var soul_stage := 0
var was_dead := false

var died_from_own_cast := false
var died_from_own_spell := false

var Map :Node2D

var last_controller_aim := Vector2(0, 0)

export var controller_path: NodePath
onready var controller :EntityController = get_node_or_null(controller_path)

onready var camera_controller :Node = get_node_or_null("CameraController")

export var properties_path: NodePath
onready var properties :Node = get_node_or_null(properties_path)

func _ready() -> void:
	Map = get_tree().get_nodes_in_group("World")[0]
	health = properties.get_health()
	health.connect("was_damaged", self, "_on_damaged")
	health.connect("died", self, "health_died")
	health.connect("hole_poked", self, "_on_hole_poked")
	health.connect("full_healed", self, "send_message", ["Your flesh is renewed"])
	health.connect("effect_changed", self, "_on_effect_changes")
	health.connect("broken_leg", self, "_on_broken_leg")
	health.connect("impacted_body_top", self, "_on_impacted_body_top")
	set_physics_process(false)
	set_process(false)


func _process(delta: float) -> void:
	flying = properties.count_items("wings") > 0
	# Apply items
	if properties.count_items("gasolineblood") and not health.blood_substance == "nitroglycerine" and health.blood > 0.01:
		health.blood_substance = "nitroglycerine"
		send_message("Your insides become volatile")
		properties.items["gasolineblood"] -= 1
	
	elif properties.count_items("waterblood") and not health.blood_substance == "water" and health.blood > 0.01:
		health.blood_substance = "water"
		send_message("Your insides become drinkable")
		properties.items["waterblood"] -= 1
	
	if properties.count_items("thickblood") > 0:
		properties.items["thickblood"] -= 1
		health.max_blood *= 2.0
		health.blood *= 2.0
		health.blood += 0.5
		health.blood = min(health.max_blood, health.blood)
		
	if properties.count_items("heal") > 0:
		properties.items["heal"] -= 1
		health.full_heal()
		
	if properties.count_items("scraps") > 0:
		properties.items["scraps"] -= 1
		properties.cloth_scraps += 1
		
	if properties.count_items("soulfulpill") > 0:
		properties.items["soulfulpill"] -= 1
		health.soul += 0.3+randf()*0.2
		
	if properties.count_items("icecube") > 0:
		properties.items["icecube"] -= 1
		health.temp_change(-5.0)
		
	if properties.count_items("heatadapt") > 0:
		properties.items["heatadapt"] -= 1
		health.death_hypertemperature += 20
		
	if properties.count_items("dissipator") > 0:
		properties.items["dissipator"] -= 1
		health.temp_regulation += 0.005
		
	if properties.count_items("shance") > 0:
		properties.items["shance"] -= 1
		health.chances += 1
		
	if properties.count_items("suarantee") > 0:
		properties.items["suarantee"] -= 1
		health.guarantees += 1
		send_message("You died... but you survived!")
	
	if properties.count_items("legs") > 0:
		if health.broken_moving_appendages > 0:
			health.broken_moving_appendages -= 1
			properties.items["legs"] -= 1
			send_message("You put on a new leg")
	
	for i in properties.count_items("gluestone"):
		if get_tree().get_nodes_in_group("Gluestone").size() <= i:
			var new_gluestone := preload("res://Companions/Gluestone.tscn").instance()
			new_gluestone.position = position
			get_parent().add_child(new_gluestone)
	
	for i in properties.count_items("egg"):
		if get_tree().get_nodes_in_group("Egg").size() <= i:
			var new_gluestone := preload("res://Companions/FloatingEgg.tscn").instance()
			new_gluestone.position = position
			get_parent().add_child(new_gluestone)
	
	if properties.count_items("bloodless") > 0:
		properties.items["bloodless"] -= 1
		health.needs_blood = false
	
	health.soul += 0.01 * delta * properties.count_items("soulfulengine")

	
	if controller.just_pressed_inputs.death_action and not dead and Config.instant_death_button:
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
		if health.blood_substance == "nitroglycerine" and health.blood > 0.01:
			var n := preload("res://Particles/Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		send_message("You should slow down to cool off")
	elif health.temperature >= 100 and temp_stage != 3:
		temp_stage = 3
		# Player explodes on high temperatures if their blood is nitro
		if health.blood_substance == "nitroglycerine" and health.blood > 0.01:
			var n := preload("res://Particles/Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		send_message("Your insides feel like they're melting")
	
	
	# Soullessness and soulfulness
	if health.soul >= 0.001 and health.soul <= 0.3 and soul_stage != -2:
		soul_stage = -2
		send_message("Your soul is dying")
	elif health.soul >= 0.3 and health.soul <= 0.6 and soul_stage != -1:
		soul_stage = -1
		send_message("Your soul is weakened")
	elif health.soul > 0.6 and health.soul <= 1.0 and soul_stage != 0:
		soul_stage = 0
		send_message("Your soul is alive")
	elif health.soul > 1.0 and health.soul <= 2.0 and soul_stage != 1:
		soul_stage = 1
		send_message("Your soul is resilient")
	elif health.soul > 2.0 and soul_stage != 2:
		soul_stage = 2
		send_message("Your soul is undying")
	


func _physics_process(delta: float) -> void:
	var controller_axis := controller.get_movement_axis()
	$Fire.visible = health.effects.has("onfire")
	if !Config.last_input_was_controller:
		looking_at = controller.get_eye_specific_direction()
	else:
		if controller_axis.length() > 10:
			last_controller_aim = controller_axis
		looking_at = last_controller_aim
	
	wand = properties.get_wand()
	if not "confused" in health.effects:
		inputs = {
			"left": controller.pressed_inputs.left,
			"right": controller.pressed_inputs.right,
			"up": controller.pressed_inputs.up,
			"down": controller.pressed_inputs.down,
			"jump": controller.pressed_inputs.move_action,
		}
	else:
		inputs = {
			"left": controller.pressed_inputs.right,
			"right": controller.pressed_inputs.left,
			"up": controller.pressed_inputs.down,
			"down": controller.pressed_inputs.up,
			"jump": controller.pressed_inputs.move_action,
		}
	if controller.just_pressed_inputs.action3 and health.poked_holes > 0 and properties.cloth_scraps > 0:
		health.poked_holes -= 1
		properties.cloth_scraps -= 1
	process_movement(delta)
	handle_wand_sprite($WandRender)
	animation_info($Player)
	
	if !Config.last_input_was_controller:
		$CastDirection.cast_to = controller.get_eye_direction() * 30
	else:
		$CastDirection.cast_to = last_controller_aim.normalized() * 30
	
	if $CastDirection.is_colliding():
		spell_cast_pos = $CastDirection.get_collision_point() - position
	else:
		spell_cast_pos = $CastDirection.cast_to
	
	
	# The wounds can cicatrize on their own
	# Bandaids help
	if health.poked_holes > 0:
		var plus :float = 0.0008 * 0.0008*properties.count_items("bandaid")
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
	if camera_controller != null: get_tree().get_nodes_in_group("HUD")[0].add_message(message)


func _on_effect_changes(effect:String, added:bool) -> void:
	match effect:
		"onfire":
			if added:
				send_message("You are on fire")
			else:
				send_message("You are not on fire")


func _on_broken_leg(amount:int) -> void:
	if camera_controller != null: camera_controller.shake_camera(8.0)
	if properties.count_items("ironknees") > 0:
		health.broken_moving_appendages -= amount
		return
	if amount != 0:
		Map.play_sound(preload("res://Sfx/broken_legs.wav"), position, 1.0, 0.8+randf()*0.4)
		if health.blood_substance == "nitroglycerine" and health.blood > 0.01:
			var n := preload("res://Particles/Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		match amount:
			1:
				send_message("Broken leg")
			2:
				send_message("Broken both legs")


func _on_DamageTimer_timeout() -> void:
	modulate = Color("#ffffff")


func _on_hole_poked():
	if camera_controller != null: camera_controller.shake_camera(3.0)
	send_message("Bleeding")
	Map.play_sound(preload("res://Sfx/pierced_flesh/piercing-1a.wav"), position, 1.0, 0.8+randf()*0.4)


func _on_frame_changed() -> void:
	if $Player.animation in ["run", "run_lookback"] and $Player.frame in [0,3]:
		Map.play_sound(preload("res://Sfx/step.wav"), position + Vector2(0, 6), 1.0, 0.8+randf()*0.4)

func _on_impacted_body_top(force: float) -> void:
	if camera_controller != null: camera_controller.shake_camera(8.0)
	if force < -health.leg_impact_resistance:
		send_message("You have hit your head too hard")
