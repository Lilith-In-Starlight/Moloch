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

var Map :TileMap

var first_check := false

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.seed = randi()
	health.connect("holes_poked", self, "_on_holes_poked")
	health.connect("was_damaged",self, "_on_damaged")
	Player = get_tree().get_nodes_in_group("Player")[0]
	Map = get_tree().get_nodes_in_group("World")[0]
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
	if (health.temperature > 45.0 and health.temperature <= 60.0) or health.soul < 0.5 or health.temperature < -100.0:
		primordial_termor = Vector2(noise.get_noise_2d(position.x, OS.get_ticks_msec()/3.0), noise.get_noise_2d(position.y, OS.get_ticks_msec()/3.0))*30
	if health.temperature > 60.0 or health.soul <= 0.0 or health.poked_holes > 4:
		if health.poked_holes > 0 or health.temperature > 60.0:
			var n:Area2D = preload("res://Particles/Explosion.tscn").instance()
			n.position = position
			get_parent().add_child(n)
		if randf() < 0.2:
			var item :Item = Items.all_items["soulfulpill"]
			if randf() < 0.02:
				item = Items.all_items["soulfulengine"]
			Map.summon_item(item, position, speed)
		queue_free()
	match state:
		STATES.IDLE:
			$Eye.position += (speed.normalized()*8 - $Eye.position)/3.0
			speed += (primordial_termor*10.0-speed)/3.0
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
				speed += (((last_seen-position).normalized()*30+primordial_termor)-speed)/3.0
			elif position.distance_to(Player.position) < 110:
				speed += ((-(last_seen-position).normalized()*30+primordial_termor)-speed)/3.0
			else:
				speed += (primordial_termor-speed)/10.0
			
			position_timer += delta
			if position_timer >= 1.0:
				state = STATES.RECOIL
				position_timer = 0.0
				speed = -(last_seen-position).normalized()*30
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
	# If the soul is unstable, the entity jitters
	if randf() < (health.needed_soul-health.soul)/15.0:
		var n := preload("res://Particles/Soul.tscn").instance()
		n.position = position
		get_parent().add_child(n)
		move_and_collide(Vector2(-1 + randf() * 2, -1 +  randf()  * 2)  * ((1.0  - health.needed_soul / 10.0)) * 5.0)


func health_object():
	return health


func looking_at():
	return Player.position


func cast_from():
	return $Eye.position + position


func _on_holes_poked(amount:int) -> void:
	match health.poked_holes:
		0:
			$Sprite.texture = preload("res://Sprites/Enemies/SoulDrone/body.png")
		_:
			$Sprite.texture = preload("res://Sprites/Enemies/SoulDrone/body_1.png")


func _on_DamageTimer_timeout() -> void:
	modulate = Color("#ffffff")


func _on_damaged(damage_type:String) -> void:
	Items.damage_visuals(self, $DamageTimer, damage_type)
