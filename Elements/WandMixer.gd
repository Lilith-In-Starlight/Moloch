extends Node2D

const SWAPPING_PARTICLES := preload("res://Particles/SwappingParticles.tscn")
const SWAPPING_DENIAL := preload("res://Particles/SwappingDenial.tscn")

const PROPERTIES := {
	0 : "Spell Cooldown",
	1 : "Usage Cooldown",
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

var id
var loaded := false


func _ready() -> void:
	add_to_group("Persistent")
	Player = get_tree().get_nodes_in_group("Player")[0]
	if !loaded: swap = Items.LootRNG.randi() % PROPERTIES.size()
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
			Items.player_wands[Items.selected_wand] = left_wand
			left_wand = player_wand
		1:
			Items.player_wands[Items.selected_wand] = right_wand
			right_wand = player_wand


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


func _on_exit() -> void:
	var data := {}
	data["side"] = side
	data["control"] = control
	data["left_wand"] = left_wand.get_json() if left_wand else "null"
	data["right_wand"] = right_wand.get_json() if right_wand else "null"
	data["swap"] = swap
	data["uses"] = uses
	data["cost"] = cost
	Items.saved_chest_data[id] = data


func update_with_id() -> void:
	loaded = true
	var data = Items.saved_chest_data[id]
	side = data["side"]
	control = data["control"]
	if data["left_wand"] != "null":
		var wand := Wand.new()
		var json = JSON.parse(data["left_wand"])
		wand.set_from_dict(json.result)
		Items.add_child(wand)
		left_wand = wand
	if data["right_wand"] != "null":
		var wand := Wand.new()
		var json = JSON.parse(data["right_wand"])
		wand.set_from_dict(json.result)
		Items.add_child(wand)
		right_wand = wand



