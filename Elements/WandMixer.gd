extends Node2D

const SWAPPING_PARTICLES := preload("res://Particles/SwappingParticles.tscn")
const SWAPPING_DENIAL := preload("res://Particles/SwappingDenial.tscn")

const PROPERTIES := {
	0 : "Cast Cooldown",
	1 : "Recharge Time",
	2 : "Heat Resistance",
	3 : "Soul Resistance",
	4 : "Projectile Speed",
}

var side :int = 0
var control :bool = false

var left_wand :Wand = null
var right_wand :Wand = null

var swap := 0
var uses := 0

var cost := 0.1

var Player :Character


func _ready() -> void:
	Player = get_tree().get_nodes_in_group("Player")[0]
	swap = Items.LootRNG.randi() % PROPERTIES.size()
	$Control/ButtonsToPress/Control/Label.text = "Swap " + PROPERTIES[swap]
	$PillarL/WandRenderSprite.visible = false
	$PillarR/WandRenderSprite.visible = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact_world"):
		if not control:
			add_wand_to_side()
		elif Player.position.distance_to(position) < 200:
			attempt_wand_swap()
	
	$PillarL/WandRenderSprite.render_wand(left_wand)
	$PillarR/WandRenderSprite.render_wand(right_wand)
	$PillarL/WandRenderSprite.visible = left_wand != null
	$PillarR/WandRenderSprite.visible = right_wand != null


func add_wand_to_side():
	var player_wand :Wand = Items.get_player_wand()
	match side:
		-1:
			if left_wand == null:
				left_wand = player_wand
				Items.player_wands.pop_at(Items.selected_wand)
			elif Items.player_wands.size() < 6:
				Items.player_wands.append(left_wand)
				left_wand = null
		1:
			if right_wand == null:
				right_wand = player_wand
				Items.player_wands.pop_at(Items.selected_wand)
			elif Items.player_wands.size() < 6:
				Items.player_wands.append(right_wand)
				right_wand = null


func swap_wands_success():
	if right_wand != null and left_wand != null:
		var n := SWAPPING_PARTICLES.instance()
		n.position = position + $Control.position + Vector2(0, -10)
		get_parent().add_child(n)
		match swap:
			0:
				var k := left_wand.cast_cooldown
				left_wand.cast_cooldown = right_wand.cast_cooldown
				right_wand.cast_cooldown = k
			1:
				var k := left_wand.recharge_cooldown
				left_wand.recharge_cooldown = right_wand.recharge_cooldown
				right_wand.recharge_cooldown = k
			2:
				var k := left_wand.heat_resistance
				left_wand.heat_resistance = right_wand.heat_resistance
				right_wand.heat_resistance = k
			3:
				var k := left_wand.soul_resistance
				left_wand.soul_resistance = right_wand.soul_resistance
				right_wand.soul_resistance = k
			4:
				var k := left_wand.projectile_speed
				left_wand.projectile_speed = right_wand.projectile_speed
				right_wand.projectile_speed = k
		
		swap = randi() % PROPERTIES.size()
		$Control/ButtonsToPress/Control/Label.text = "Swap " + PROPERTIES[swap]
		if randf() < 0.4:
			Player.health.poke_hole(1)


func attempt_wand_swap():
	if uses <= 3:
		swap_wands_success()
	elif uses == 4:
		var n = SWAPPING_DENIAL.instance()
		n.position = position + $Control.position + Vector2(0, -10)
		get_parent().add_child(n)
		
		n = preload("res://Particles/Earthquake.tscn").instance()
		n.position = position  + $Control.position - Vector2(0, 16)
		get_parent().add_child(n)
	
	uses += 1


func _on_PillarL_body_entered(body: Node) -> void:
	side = -1


func _on_PillarR_body_entered(body: Node) -> void:
	side = 1


func _on_Pillar_body_exited(body: Node) -> void:
	side = 0
	control = false


func _on_Control_body_entered(body: Node) -> void:
	control = true
