extends KinematicBody2D

enum STATES {
	IDLE,
	POSITIONING,
	RECOIL,
	SEARCHING,
}

var Player :KinematicBody2D
var Map :Node2D

var state :int = STATES.IDLE
var speed := Vector2(0, 0)

var position_timer := 0.0

var last_seen := Vector2(0, 0)

var noise := OpenSimplexNoise.new()

var health := LegacyFlesh.new()

var first_check := false

var spell :Spell = Items.pick_random_spell(Items.WorldRNG)

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.seed = randi()
	health.connect("holes_poked", self, "_on_holes_poked")
	health.connect("was_damaged",self, "_on_damaged")
	Map = get_tree().get_nodes_in_group("World")[0]
	Player = get_tree().get_nodes_in_group("Player")[0]
	if Player.position.distance_to(position) < 500:
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
	if (health.temperature > 45.0 and health.temperature <= 60.0) or health.soul < 0.5:
		primordial_termor = Vector2(noise.get_noise_2d(position.x, OS.get_ticks_msec()/3.0), noise.get_noise_2d(position.y, OS.get_ticks_msec()/3.0))*30
	# Death
	if health.temperature > 60.0 or health.soul <= 0.0 or health.poked_holes > 10 or health.temperature < -120.0:
		if health.poked_holes > 3 or health.temperature > 60.0:
			var n:Area2D = preload("res://Particles/Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		if randf() < 0.1:
			Map.summon_spell(spell, position, speed)
		queue_free()
	match state:
		STATES.IDLE:
			$Aim.visible = false
			$AimLine.visible = false
			$Eye.position += (speed.normalized()*10 - $Eye.position)/3.0
			speed += (primordial_termor*30.0-speed)/3.0
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider() == Player:
					last_seen = Player.position
					state = STATES.POSITIONING
			position_timer = 0.0
		STATES.POSITIONING:
			$Eye.position += ((last_seen-position).normalized()*10 - $Eye.position)/3.0
			if $RayCast2D.is_colliding():
				if not $RayCast2D.get_collider() == Player:
					state = STATES.SEARCHING
					$Aim.visible = false
					$AimLine.visible = false
				elif position_timer < 0.5:
					last_seen = Player.position
					$Aim.visible = false
					$AimLine.visible = false
				else:
					$Aim.position = last_seen - position
					$Aim.visible = true
					$AimLine.visible = true
					$AimLine.points[0] = $Eye.position
					$AimLine.points[1] = last_seen - position
			else:
				state = STATES.SEARCHING
			if position.distance_to(Player.position) > 45:
				speed += (((last_seen-position).normalized()*100+primordial_termor)-speed)/3.0
			elif position.distance_to(Player.position) < 60:
				speed += ((-(last_seen-position).normalized()*100+primordial_termor)-speed)/3.0
			else:
				speed += (primordial_termor-speed)/8.0
			
			position_timer += delta
			if position_timer >= 0.9:
				$Aim.visible = false
				$AimLine.visible = false
				state = STATES.RECOIL
				position_timer = 0.0
				speed = -(last_seen-position).normalized()*30
				var orb := spell.entity.instance()
				orb.CastInfo.goal = last_seen
				orb.CastInfo.Caster = self
				get_parent().add_child(orb)

		STATES.RECOIL:
			$Aim.visible = false
			$AimLine.visible = false
			$Eye.position += ((last_seen-position).normalized()*10 - $Eye.position)/3.0
			speed *= 0.75
			position_timer += delta
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider() == Player:
					last_seen = last_seen.move_toward(Player.position, 3*delta*60)
			if position_timer >= 0.5:
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
			$Aim.visible = false
			$AimLine.visible = false
			$Eye.position += ((last_seen-position).normalized()*10 - $Eye.position)/3.0
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
	# If the soul is unstable, the entity jitters
	if randf() < (health.needed_soul-health.soul)/15.0:
		var n := preload("res://Particles/Soul.tscn").instance()
		n.position = position
		get_parent().add_child(n)
		move_and_collide(Vector2(-1 + randf() * 2, -1 +  randf()  * 2)  * ((1.0  - health.needed_soul / 10.0)) * 5.0)


func health_object():
	return health


func looking_at():
	return last_seen


func cast_from():
	return $Eye.position + position


func _on_holes_poked(amount:int) -> void:
	match health.poked_holes:
		0:
			$Body.texture = preload("res://Sprites/Enemies/SpellMachine/body.png")
		1:
			$Body.texture = preload("res://Sprites/Enemies/SpellMachine/body1.png")
		2:
			$Body.texture = preload("res://Sprites/Enemies/SpellMachine/body2.png")
		3:
			$Body.texture = preload("res://Sprites/Enemies/SpellMachine/body3.png")
		_:
			$Body.texture = preload("res://Sprites/Enemies/SpellMachine/body4.png")


func _on_DamageTimer_timeout() -> void:
	modulate = Color("#ffffff")


func _on_damaged(damage_type:String) -> void:
	Items.damage_visuals(self, $DamageTimer, damage_type)


func _on_VisibilityEnabler2D_screen_entered() -> void:
	$RayCast2D.enabled = true


func _on_VisibilityEnabler2D_screen_exited() -> void:
	$RayCast2D.enabled = false
