extends KinematicBody2D


enum STATES {
	NORMAL,
	SEARCHING,
}

var state :int = STATES.NORMAL
var Player :KinematicBody2D
var speed := Vector2(0, 0)
var noise := OpenSimplexNoise.new()
var first_check := false
var last_seen := Vector2(0, 0)
var search_time := 0.0
var health := Flesh.new()
var wand := Wand.new()
var Map :Node2D

var loaded_data := {}


func _ready():
	add_to_group("Persistent")
	if wand.spells.empty():
		wand.fill_with_random_spells()
	Items.add_child(wand)
	Map = get_tree().get_nodes_in_group("World")[0]
	noise.seed = hash(self)
	
	health.add_blood()
	health.add_body()
	health.add_soul()
	health.add_temperature()
	health.connect("died", self, "health_died")
	health.connect("was_damaged",self, "_on_damaged")
	health.body_module.connect("hole_poked", self, "_on_hole_poked")
	health.blood_module.amount = 0.4
	add_child(health)
	
	Player = get_tree().get_nodes_in_group("Player")[0]
	wand.recharge_cooldown = max(wand.recharge_cooldown, 1.5)
	if Player.position.distance_to(position) < 500 and not first_check:
		queue_free()


func _physics_process(delta):
	$Fire.visible = health.effects.has("onfire")
	
	$WandRenderSprite.render_wand(wand)
	
	if health.body_module:
		for i in min(health.body_module.holes, 6):
			if randf()>0.9:
				var n :RigidBody2D = preload("res://Particles/Blood.tscn").instance()
				n.position = position + Vector2(0, 6)
				n.linear_velocity = Vector2(-200 + randf()*400, -80 + randf()*120)
				n.modulate = ColorN("red")
				get_parent().add_child(n)
	var frames := Engine.get_frames_drawn()
	$Senses.cast_to = speed
	$Eye.cast_to = (Player.position-position).normalized()*500
	if not first_check:
		if Player.position.distance_to(position) < 500:
			queue_free()
		var tcol :KinematicCollision2D = move_and_collide(Vector2(0, 0), true, true, true)
		if tcol != null:
			if tcol.collider != self:
				queue_free()
		first_check = true
	
	var primordial_tremor := Vector2(noise.get_noise_2d(position.x, frames), noise.get_noise_2d(position.y, frames))*5
	match state:
		STATES.NORMAL:
			if $Eye.is_colliding() and $Eye.get_collider() == Player:
				var goal := (position - Player.position).normalized()*130 + Player.position
				speed = lerp(speed, primordial_tremor*30 + (goal - position), 0.2)
				last_seen = Player.position
				$WandRenderSprite.rotation = lerp_angle($WandRenderSprite.rotation, Player.position.angle_to_point(position) + PI/4.0, 0.05)
				$WandRenderSprite.position = lerp($WandRenderSprite.position, Vector2(cos(Player.position.angle_to_point(position)), sin(Player.position.angle_to_point(position)))*30, 0.5)
				wand.run(self)
			else:
				speed = lerp(speed, primordial_tremor*60, 0.2)
				if last_seen != Vector2(0, 0):
					state = STATES.SEARCHING
					search_time = 0.0
			speed = move_and_slide(speed)
		
		STATES.SEARCHING:
			search_time += delta
			if $Eye.is_colliding() and $Eye.get_collider() == Player:
				state = STATES.NORMAL
			else:
				speed = lerp(speed, primordial_tremor*20 + (last_seen - position), 0.2)
			
			if search_time > 12.0:
				state = STATES.NORMAL
				last_seen = Vector2(0, 0)
			speed = move_and_slide(speed)


func health_object() -> Flesh:
	return health


func health_died():
	if randf() < 0.1:
		Map.summon_wand(wand, position, speed)
	else:
		wand.queue_free()
	queue_free()


func cast_from():
	return $WandRenderSprite.position + position + Vector2(cos($WandRenderSprite.rotation-PI/4.0), sin($WandRenderSprite.rotation-PI/4.0))*5


func looking_at():
	return Vector2(cos($WandRenderSprite.rotation-PI/4.0), sin($WandRenderSprite.rotation-PI/4.0))*50 + position


func _on_DamageTimer_timeout() -> void:
	modulate = Color("#ffffff")


func _on_damaged(damage_type:String) -> void:
	Items.damage_visuals(self, $DamageTimer, damage_type)


func _on_hole_poked(amt: float) -> void:
	Map.play_sound(preload("res://Sfx/pierced_flesh/piercing-1a.wav"), position, 1.0, 0.8+randf()*0.4)


func _on_VisibilityEnabler2D_screen_entered() -> void:
	$Eye.enabled = true
	$Senses.enabled = true


func _on_VisibilityEnabler2D_screen_exited() -> void:
	$Eye.enabled = false
	$Senses.enabled = false


func _on_exit():
	var data := {}
	data["type"] = "incomplete"
	data["position"] = position
	data["state"] = state
	data["speed"] = speed
	data["search_time"] = search_time
	data["last_seen"] = last_seen
	data["health"] = health.get_as_dict()
	data["first_check"] = first_check
	data["wand"] = wand.get_json()
	Items.saved_entity_data.append(data)


func set_data(dict: Dictionary):
	position = dict["position"]
	state = dict["state"]
	speed = dict["speed"]
	search_time = dict["search_time"]
	last_seen = dict["last_seen"]
	health.set_from_dict(dict["health"])
	first_check = dict["first_check"]
	var json := JSON.parse(dict["wand"])
	wand.set_from_dict(json.result)
	loaded_data.clear()
