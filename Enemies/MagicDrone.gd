extends KinematicBody2D

enum STATES {
	IDLE,
	POSITIONING,
	RECOIL,
	SEARCHING,
}

var Player :KinematicBody2D

var state :int = STATES.IDLE
var speed := Vector2(0, 0)

var position_timer := 0.0

var last_seen := Vector2(0, 0)

var noise := OpenSimplexNoise.new()

var health := Flesh.new()

var Map :Node2D

var first_check := false

var loaded_data := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Persistent")
	noise.seed = randi()
	health.add_body()
	health.add_temperature()
	health.add_soul()
	health.body_module.connect("hole_poked", self, "_on_holes_poked")
	health.connect("was_damaged",self, "_on_damaged")
	health.connect("died", self, "_on_died")
	health.temperature_module.max_temperature = 60.0
	health.temperature_module.min_temperature = -120.0
	health.body_module.max_holes = 4
	add_child(health)
	
	Player = get_tree().get_nodes_in_group("Player")[0]
	Map = get_tree().get_nodes_in_group("World")[0]
	if Player.position.distance_to(position) < 500 and not first_check:
		queue_free()
	

func _physics_process(delta):
	if not first_check:
		if Player.position.distance_to(position) < 500:
			queue_free()
		var tcol :KinematicCollision2D = move_and_collide(Vector2(0, 0), true, true, true)
		if tcol != null:
			if tcol.collider != self:
				queue_free()
		first_check = true
	$RayCast2D.cast_to = (Player.position - position).normalized()*300
	
	var primordial_termor := Vector2(noise.get_noise_2d(position.x, OS.get_ticks_msec()/300.0), noise.get_noise_2d(position.y, OS.get_ticks_msec()/300.0))*30
	
	if (health.temperature_module and health.temperature_module.temperature > 45.0 and health.temperature_module.temperature <= 60.0) or (health.soul_module and health.soul_module.amount < 0.5):
		primordial_termor = Vector2(noise.get_noise_2d(position.x, OS.get_ticks_msec()/3.0), noise.get_noise_2d(position.y, OS.get_ticks_msec()/3.0))*30
	
	match state:
		STATES.IDLE:
			$Eye.position += (speed.normalized()*8 - $Eye.position)/3.0
			speed += (primordial_termor*30.0-speed)/3.0
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider() == Player:
					last_seen = Player.position
					state = STATES.POSITIONING
			position_timer = 0.0
		STATES.POSITIONING:
			$Eye.position += ((last_seen-position).normalized()*8 - $Eye.position)/3.0
			if $RayCast2D.is_colliding():
				if not $RayCast2D.get_collider() == Player:
					state = STATES.SEARCHING
				else:
					last_seen = Player.position
			else:
				state = STATES.SEARCHING
			if position.distance_to(Player.position) > 120:
				speed += (((last_seen-position).normalized()*100+primordial_termor)-speed)/3.0
			elif position.distance_to(Player.position) < 110:
				speed += ((-(last_seen-position).normalized()*100+primordial_termor)-speed)/3.0
			else:
				speed += (primordial_termor-speed)/8.0
			
			position_timer += delta
			if position_timer >= 0.5:
				state = STATES.RECOIL
				position_timer = 0.0
				speed = -(last_seen-position).normalized()*100
				var orb := preload("res://Spells/ShatteringOrb.tscn").instance()
				orb.CastInfo.goal = Player.position
				orb.CastInfo.Caster = self
				get_parent().add_child(orb)

		STATES.RECOIL:
			$Eye.position += ((last_seen-position).normalized()*8 - $Eye.position)/3.0
			speed *= 0.75
			position_timer += delta
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider() == Player:
					last_seen = Player.position
			if position_timer >= 0.4:
				if $RayCast2D.is_colliding():
					if $RayCast2D.get_collider() == Player:
						state = STATES.POSITIONING
						position_timer = 0.0
					else:
						state = STATES.SEARCHING
						position_timer = 0.0
				else:
					state = STATES.SEARCHING
					position_timer = 0.0

		STATES.SEARCHING:
			$Eye.position += ((last_seen-position).normalized()*8 - $Eye.position)/3.0
			position_timer += delta
			if position.distance_to(last_seen) > 75:
				speed += (((last_seen-position).normalized()*30+primordial_termor)-speed)/3.0
			elif position.distance_to(last_seen) < 60:
				speed += ((-(last_seen-position).normalized()*30+primordial_termor)-speed)/3.0
			if position_timer >= 2.5:
				state = STATES.IDLE
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider() == Player:
					last_seen = Player.position
					state = STATES.POSITIONING
					position_timer = 0.0

	speed = move_and_slide(speed)


func health_object():
	return health


func looking_at():
	return Player.position


func cast_from():
	return $Eye.position + position


func _on_holes_poked(amount:int) -> void:
	match health.body_module.holes:
		0:
			$Sprite.texture = preload("res://Sprites/Enemies/SoulDrone/body.png")
		_:
			$Sprite.texture = preload("res://Sprites/Enemies/SoulDrone/body_1.png")


func _on_DamageTimer_timeout() -> void:
	modulate = Color("#ffffff")


func _on_damaged(damage_type:String) -> void:
	Items.damage_visuals(self, $DamageTimer, damage_type)



func _on_VisibilityEnabler2D_screen_entered() -> void:
	$RayCast2D.enabled = true


func _on_VisibilityEnabler2D_screen_exited() -> void:
	$RayCast2D.enabled = false


func _on_died():
	if health.cause_of_death == Flesh.DEATH_TYPES.HOLES or health.cause_of_death == Flesh.DEATH_TYPES.HYPER:
		var n:Area2D = preload("res://Particles/Explosion.tscn").instance()
		n.position = position
		get_parent().add_child(n)
	if randf() < 0.2:
		if Items.player_health.soul_module:
			if Items.player_health.soul_module.amount <= Items.player_health.soul_module.maximum or (Items.player_health.soul_module.amount > Items.player_health.soul_module.maximum and randf() < 0.2):
				var item :Item = Items.all_items["soulfulpill"]
				if randf() < 0.02:
					item = Items.all_items["soulfulengine"]
				Map.summon_item(item, position, speed)
	queue_free()


func _on_exit():
	var data := {}
	data["type"] = "soulmachine"
	data["position"] = position
	data["state"] = state
	data["speed"] = speed
	data["position_timer"] = position_timer
	data["last_seen"] = last_seen
	data["health"] = health.get_as_dict()
	data["first_check"] = first_check
	Items.saved_entity_data.append(data)


func set_data(dict: Dictionary):
	position = dict["position"]
	state = dict["state"]
	speed = dict["speed"]
	position_timer = dict["position_timer"]
	last_seen = dict["last_seen"]
	health.set_from_dict(dict["health"])
	first_check = dict["first_check"]
