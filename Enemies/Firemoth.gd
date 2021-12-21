extends FloatingOrb


const attack := preload("res://Spells/Fireball.tscn")

var attacking :Node2D = null

var Noise := OpenSimplexNoise.new()

var eye_dir := Vector2(0, 0)

var timer := 0.0


func _ready() -> void:
	health.max_blood = 5.0
	health.blood = 5.0
	health.needs_blood = true
	health.blood_substance = "lava"
	health.death_hypertemperature = 10000000.0
	health.temp_regulation = 0.1
	Noise.seed = hash(self)
	health.connect("died", self, "_death")


func _physics_process(delta: float) -> void:
	direction = direction.rotated(Noise.get_noise_3d(position.x, position.y, Engine.get_frames_drawn()) * 0.1)
	
	if direction == Vector2(0, 0):
		direction = Vector2(0, 1)
	
	timer += delta
	
	$RayCast.cast_to = Player.position - position
	
	if $RayCast.is_colliding():
		if $RayCast.get_collider() == Player:
			attacking = Player
		else:
			attacking = null
	else:
		attacking = null
	
	if attacking:
		speed_n = lerp(speed_n, 50 + Noise.get_noise_2d(Engine.get_frames_drawn() * 0.5, 141864) * 10.0, 0.2)
		if position.distance_to(Player.position) > 150 + Noise.get_noise_2d(Engine.get_frames_drawn() * 0.5, 516813) * 30.0:
			direction = (Player.position - position).normalized().rotated(Noise.get_noise_2d(Engine.get_frames_drawn() * 0.5, 29849) * 0.1)
		else:
			direction = -(Player.position - position).normalized().rotated(Noise.get_noise_2d(Engine.get_frames_drawn() * 0.5, 29849) * 0.1)
		if $AttackingTimer.is_stopped():
			$AttackingTimer.start()
	elif not $AttackingTimer.is_stopped():
		$AttackingTimer.stop()
	else:
		speed_n = Noise.get_noise_1d(Engine.get_frames_drawn()*0.001+100) * 60 * 3
		speed_n = abs(speed_n)
	
	if Player.position.x > position.x:
		$Animations.scale.x = 1
	else:
		$Animations.scale.x = -1
	
	bleed()
	health.process_health(delta)


func looking_at() -> Vector2:
	return Player.position


func cast_from() -> Vector2:
	return position + (Player.position - position).normalized() * 20


func health_object() -> Flesh:
	return health


func _death() -> void:
	Config.give_achievement("armageddont")



func _on_AttackingTimer_timeout() -> void:
	$Animations.play("attack")


func _on_animation_finished() -> void:
	if $Animations.animation == "attack":
		$Animations.play("default")
		var n := attack.instance()
		n.CastInfo.goal = Player.position
		n.CastInfo.Caster = self
		get_parent().add_child(n)


func bleed() -> void:
	# If the player is bleeding
	if health.poked_holes > 0 and health.blood > 0.01:
		if health.blood_substance == "water" and "onfire" in health.effects:
			health.effects.erase("onfire")
		# Emit blood particles 
		for i in min(health.poked_holes, 12):
			if randf()>0.9:
				var n :RigidBody2D = preload("res://Particles/Blood.tscn").instance()
				n.substance = "lava"
				n.position = position + Vector2(0, 6)
				n.linear_velocity = Vector2(-200 + randf()*400, -80 + randf()*120)
				n.substance = health.blood_substance
				get_parent().add_child(n)
