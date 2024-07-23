extends Character

class_name PlayerCharacter


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

var prepare_for_setup := {}


func _ready() -> void:
	if properties != null and not prepare_for_setup.empty():
		set_data(prepare_for_setup)
	Map = get_tree().get_nodes_in_group("World")[0]
	health = properties.get_health()
	health.connect("was_damaged", self, "_on_damaged")
	health.connect("died", self, "health_died")
	health.body_module.connect("hole_poked", self, "_on_hole_poked")
	health.connect("full_healed", self, "send_message", ["Your flesh is renewed"])
	health.connect("effect_changed", self, "_on_effect_changes")
	health.body_module.connect("broken_legs", self, "_on_broken_leg")
	health.body_module.connect("impacted_body_top", self, "_on_impacted_body_top")
	health.temperature_module.connect("temperature_state_changed", self, "_on_temperature_state_changed")
	health.soul_module.connect("soul_state_changed", self, "_on_soul_state_changed")
	$DiscordUpdater.health = health
	if Items.retrieved_player_data.has("position"):
		position = Items.retrieved_player_data["position"]
	if Items.retrieved_player_data.has("velocity"):
		speed = Items.retrieved_player_data["velocity"]
	Items.retrieved_player_data.clear()
	set_physics_process(false)
	set_process(false)


func _process(delta: float) -> void:
	if health.body_module:
		if health.body_module.broken_legs == 2:
			$CollisionShape2D.shape.extents = Vector2(10.5, 3)
			$CollisionShape2D.position.y = 8
		else:
			$CollisionShape2D.shape.extents = Vector2(3, 10.5)
			$CollisionShape2D.position.y = 0
	flying = properties.count_items("wings") > 0
	# Apply items
	
	if properties.count_items("shance") > 0:
		properties.items["shance"] -= 1
		health.chances += 1
		
	if properties.count_items("suarantee") > 0:
		properties.items["suarantee"] -= 1
		health.guarantees += 1
		send_message("You died... but you survived!")
	
	if health.blood_module:
		if properties.count_items("gasolineblood") and not health.blood_module.substance == "nitroglycerine" and health.blood_module.amount > 0.01:
			health.blood_module.substance = "nitroglycerine"
			send_message("Your insides become volatile")
			properties.items["gasolineblood"] -= 1
		
		elif properties.count_items("waterblood") and not health.blood_module.substance == "water" and health.blood_module.amount > 0.01:
			health.blood_module.substance = "water"
			send_message("Your insides become drinkable")
			properties.items["waterblood"] -= 1
	
		if properties.count_items("thickblood") > 0:
			properties.items["thickblood"] -= 1
			health.blood_module.maximum *= 2.0
			health.blood_module.amount *= 2.0
			health.blood_module.amount += 0.5
			health.blood_module.amount = min(health.blood_module.maximum, health.blood_module.amount)
		
		if properties.count_items("bloodless") > 0:
			properties.items["bloodless"] -= 1
			health.blood_module.is_vital = false
		
	if properties.count_items("heal") > 0:
		properties.items["heal"] -= 1
		health.full_heal()
		
	if properties.count_items("scraps") > 0:
		properties.items["scraps"] -= 1
		properties.cloth_scraps += 1
	
	if properties.count_items("swarm") > 0:
		properties.items["swarm"] -= 1
		for _i in randi() % 6 + 6:
			var new_empress = load("res://PlayerSwarm.tscn").instance()
			get_parent().add_child(new_empress)
			new_empress.health.set_from_dict(health.get_as_dict())
			new_empress.position = position + Vector2(-50 + randf() * 100, 0)
			new_empress._on_generated_world()
		
	
	if health.soul_module:
		if properties.count_items("soulfulpill") > 0:
			properties.items["soulfulpill"] -= 1
			health.soul_module.change_soul(0.3+randf()*0.2)
		
		health.soul_module.change_soul(0.01 * delta * properties.count_items("soulfulengine"))
	
	if health.temperature_module:
		if properties.count_items("icecube") > 0:
			properties.items["icecube"] -= 1
			health.temperature_module.temp_change(-5.0)
			
		if properties.count_items("heatadapt") > 0:
			properties.items["heatadapt"] -= 1
			health.temperature_module.max_temperature += 20
			
		if properties.count_items("dissipator") > 0:
			properties.items["dissipator"] -= 1
			health.temperature_module.regulation += 0.01
	
	if health.body_module:
		if properties.count_items("legs") > 0 and health.body_module.broken_legs > 0:
			health.body_module.restore_legs(1)
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

	
	if controller.just_pressed_inputs.death_action and not dead and Config.instant_death_button:
		health.self_terminate()	


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
	
	
	if health.body_module:
		if controller.just_pressed_inputs.action3 and health.body_module.holes > 0 and properties.cloth_scraps > 0:
			health.body_module.holes -= 1
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
	if health.body_module:
		if health.body_module.holes > 0:
			var plus :float = 0.0008 * 0.0008 * properties.count_items("bandaid")
			if randf() < 0.0005 + plus:
				health.body_module.holes -= 1
				if health.body_module.holes < 0:
					health.body_module.holes = 0
				if health.body_module.holes == 0:
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
		health.body_module.broken_legs -= amount
		return
	
	if amount != 0:
		Map.play_sound(preload("res://Sfx/broken_legs.wav"), position, 1.0, 0.8+randf()*0.4)
		
		if health.blood_module:
			if health.blood_module.substance == "nitroglycerine" and health.blood_module.amount > 0.01:
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


func _on_hole_poked(_amt: float):
	if camera_controller != null: camera_controller.shake_camera(3.0)
	send_message("Bleeding")
	Map.play_sound(preload("res://Sfx/pierced_flesh/piercing-1a.wav"), position, 1.0, 0.8+randf()*0.4)


func _on_frame_changed() -> void:
	if $Player.animation in ["run", "run_lookback"] and $Player.frame in [0,3]:
		Map.play_sound(preload("res://Sfx/step.wav"), position + Vector2(0, 6), 1.0, 0.8+randf()*0.4)

func _on_impacted_body_top(force: float) -> void:
	if camera_controller != null: camera_controller.shake_camera(8.0)
	if force < -health.body_module.leg_impact_resistance:
		send_message("You have hit your head too hard")

func _on_temperature_state_changed(_previous: int, new_state: int) -> void:
	if new_state == -2:
		send_message("You feel like you're freezing")
	elif new_state == -1:
		send_message("You feel a bit cold")
	elif new_state == 0:
		send_message("The temperature is right")
	elif new_state == 1:
		send_message("You feel a bit overheated")
	elif new_state == 2:
		send_message("You should slow down to cool off")
		# Player explodes on high temperatures if their blood is nitro
		if health.blood_module:
			if health.blood_module.substance == "nitroglycerine" and health.blood_module.amount > 0.01:
				var n := preload("res://Particles/Explosion.tscn").instance()
				n.position = position
				get_parent().add_child(n)
	elif new_state == 3:
		send_message("Your insides feel like they're melting")
		# Player explodes on high temperatures if their blood is nitro
		if health.blood_module:
			if health.blood_module.substance == "nitroglycerine" and health.blood_module.amount > 0.01:
				var n := preload("res://Particles/Explosion.tscn").instance()
				n.position = position
				get_parent().add_child(n)


func _on_soul_state_changed(_previous: int, new_state: int) -> void:
	if new_state == -2:
		send_message("Your soul is dying")
	elif new_state == -1:
		send_message("Your soul is weakened")
	elif new_state == 0:
		send_message("Your soul is alive")
	elif new_state == 1:
		send_message("Your soul is overwhelmed")
	elif new_state == 2:
		send_message("Your soul is more real than the world")


func set_data(data: Dictionary) -> void:
	if not properties:
		prepare_for_setup = data
	else:
		properties.set_data(prepare_for_setup)
		data.clear()
