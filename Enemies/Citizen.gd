extends Character


var Player :Character
var was_on_floor := false
var held_jump := 0.0

var last_seen := Vector2(0, 0)

var Map :TileMap

var first_check := false

var aim := last_seen


func _ready() -> void:
	wand = Wand.new()
	for i in wand.spells.size():
		wand.spells[i] = null
	wand.spells[0] = Items.pick_random_spell()
	wand.full_recharge = 1.5 + randf()*2.0
	wand.spell_recharge = 0.5 + randf()*1.3
	Map = get_tree().get_nodes_in_group("World")[0]
	Player = get_tree().get_nodes_in_group("Player")[0]
	health.connect("died", self, "health_died_second")
	health.connect("hole_poked", self, "_on_hole_poked")


func _physics_process(delta: float) -> void:
	$Fire.visible = health.effects.has("onfire")
	if not first_check:
		if Player.position.distance_to(position) < 500:
			queue_free()
		var tcol :KinematicCollision2D = move_and_collide(Vector2(0, 0), true, true, true)
		if tcol != null:
			if tcol.collider != self:
				queue_free()
		first_check = true
	walk_accel = 50.0
	$RayCast2D.position.x = speed.x * delta
	$RayCast2D2.cast_to.x = speed.x * delta
	$PlayerFinder.cast_to = (Player.position - position).normalized() * 250
	$AimRay.cast_to = (aim - position).normalized() * 350
	var aa :Vector2 = aim
	if $AimRay.is_colliding():
		aa = $AimRay.get_collision_point()
	if $PlayerFinder.is_colliding() and $PlayerFinder.get_collider() == Player:
		if not wand.running:
			wand.run(self)
		aim = lerp(aim, Player.position, 0.03)
		$Line2D.visible = true
		$Line2D.points[1] = aa - position
		$Line2D.points[0] = cast_from() - position
		last_seen = Player.position
		looking_at = Player.position
		if Player.position.x > position.x + 60:
			inputs["right"] = true
			inputs["left"] = false
		elif Player.position.x < position.x - 60:
			inputs["right"] = false
			inputs["left"] = true
		else:
			inputs["right"] = false
			inputs["left"] = false
		if (!$RayCast2D.is_colliding() and !$RayCast2D2.is_colliding()) and is_on_floor():
			inputs["jump"] = true
		elif Player.position.y < position.y - 5 and (is_on_floor() or state == STATES.WALL) and not inputs["jump"]:
			inputs["jump"] = true
			held_jump = 0.4
		elif held_jump <= 0.0:
			inputs["jump"] = false
	else:
		$Line2D.visible = false
		looking_at = last_seen
		if last_seen.x > position.x:
			inputs["right"] = true
			inputs["left"] = false
		elif last_seen.x < position.x:
			inputs["right"] = false
			inputs["left"] = true
		else:
			inputs["right"] = false
			inputs["left"] = false
		if (!$RayCast2D.is_colliding() and !$RayCast2D2.is_colliding()) and is_on_floor():
			inputs["jump"] = true
		elif last_seen.y < position.y - 2 and (is_on_floor() or state == STATES.WALL) and not inputs["jump"]:
			inputs["jump"] = true
			held_jump = 0.4
		elif held_jump <= 0.0:
			inputs["jump"] = false
	
	held_jump -= delta
	
	inputs["down"] = Player.position.y > position.y + 10
	process_movement(delta)
	animation_info($AnimatedSprite)


func _on_DamageTimer_timeout() -> void:
	modulate = Color("#ffffff")


func _on_hole_poked():
	Map.play_sound(preload("res://Sfx/pierced_flesh/piercing-1a.wav"), position, 1.0, 0.8+randf()*0.4)


func health_died_second():
	queue_free()


func cast_from():
	return (aim - position).normalized()*32 + position


func looking_at():
	return aim
