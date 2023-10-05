extends Node2D


var spells := []
var prices := []
var Player :Character

var soul_spell := false
var soul_cost := 0.1
var max_soul := 1.0

var time := 0.0

var id : int

var loaded := false

func _ready() -> void:
	add_to_group("Persistent")
	Player = get_tree().get_nodes_in_group("Player")[0]
	if loaded:
		return
	for i in $Items.get_child_count():
		var spr := Sprite.new()
		$Items.get_child(i).add_child(spr)
		spr.texture = get_item_in_tier(Items.LootRNG.randi()%3 + 1).texture
		spr.position = Vector2(-8, -16)
	
	


func _process(delta: float) -> void:
	time += delta
	
	if !Rect2(position, Vector2(66, 33) * 8).has_point(Player.position):
		$SoulParticles.emitting = false
		return
	
	if prices.empty():
		for i in spells.size():
			prices.append(assign_price(spells[i]))
		
		if Items.player_health.soul_module:
			soul_spell = Items.count_player_items("DE4L") and Items.LootRNG.randf() < 0.01 * Items.count_player_items("DE4L")
			soul_cost = Items.player_health.soul_module.amount * 0.9
			max_soul = max(Items.player_health.soul_module.amount, Items.player_health.soul_module.maximum)
			if soul_spell:
				var a := spells.size()-1
				spells.remove(a)
				var spr := $Items.get_child(a).get_child(0)
				spr.texture = get_item_in_tier(Items.LootRNG.randi()%2 + 3).texture
				spr.position = Vector2(-8, -16)
	
	if Items.player_health.soul_module:
		$SoulParticles.emitting = soul_spell
		max_soul = max(Items.player_health.soul_module.amount, max_soul)
	
	if Items.player_health.blood_module:
		for i in $Sacrifice.get_overlapping_bodies():
			if i.get("spell"):
				if i.is_in_group("SpellItemEntity") and not i.spell.is_modifier():
					Items.player_health.blood_module.amount = clamp(Items.player_health.blood_module.amount + assign_price(i.spell.id) * 0.7, 0.0, Items.player_health.blood_module.maximum)
					i.queue_free()
	
	var selected := -1
	var j := 0
	for i in $Items.get_children():
		var mult := 6.0
		if Player.position.distance_to(i.position + position) < 30.0:
			mult = 12.0
			selected = j
		i.rotation = lerp_angle(i.rotation, sin(time*mult+j*0.1)*0.3, 0.1)
		j += 1
	
	if selected == $Items.get_child_count() - 1 and soul_spell and Items.player_health.soul_module:
		$BloodBar.modulate = Color("#b9ffad")
		$BloodBar/CostBar.modulate = Color("#25ca0d")
		$BloodBar/BloodBar.max_value = max_soul
		$BloodBar/BloodBar.value = Items.player_health.soul_module.amount
		$BloodBar/CostBar.value = Items.player_health.soul_module.amount - soul_cost
		$BloodBar/BloodBar/Label.text = "S0UL"
	elif Items.player_health.blood_module:
		$BloodBar.modulate = Color("#ffadad")
		$BloodBar/CostBar.modulate = Color("#960000")
		$BloodBar/BloodBar/Label.text = "BLOOD"
		$BloodBar/BloodBar.max_value = Items.player_health.blood_module.maximum
		$BloodBar/BloodBar.value = Items.player_health.blood_module.amount
		$BloodBar/CostBar.value = Items.player_health.blood_module.amount - prices[selected]
	
	$BloodBar/CostBar.max_value = $BloodBar/BloodBar.max_value
	
	if selected == -1:
		$BloodBar/CostBar.visible = false
		return
	
	$BloodBar/CostBar.visible = true
	if selected == $Items.get_child_count() - 1 and soul_spell and Items.player_health.soul_module:
		if Input.is_action_just_pressed("interact_world") and $Items.get_child(selected).visible and Items.player_spells.size() < 6 and Items.player_health.soul_module.amount - soul_cost > 0.0:
			$Items.get_child(selected).visible = false
			Items.player_spells.append(Items.all_spells[spells[selected]])
			Items.player_health.shatter_soul(soul_cost)
			if randf() < 0.25:
				Items.player_health.poke_hole()
	else:
		if Items.player_health.blood_module:
			if Input.is_action_just_pressed("interact_world") and $Items.get_child(selected).visible and Items.player_spells.size() < 6 and Items.player_health.blood_module.amount - prices[selected] > 0.0:
				$Items.get_child(selected).visible = false
				Items.player_spells.append(Items.all_spells[spells[selected]])
				Items.player_health.blood_module.amount -= prices[selected]


func _on_exit() -> void:
	var data := {}
	data["children"] = []
	for idx in $Items.get_child_count():
		var child = $Items.get_child(idx)
		data["children"].append(child.visible)
	data["spells"] = []
	for spell in spells:
		data["spells"].append(spell)
	data["prices"] = prices
	data["soul_cost"] = soul_cost
	data["soul_spell"] = soul_spell
	Items.saved_chest_data[id] = data
	

func update_with_id():
	loaded = true
	var data = Items.saved_chest_data[id]
	for idx in data["children"].size():
		var child = $Items.get_child(idx)
		child.visible = data["children"][idx]
		if !data["children"][idx]: print(data["children"][idx])
	for idx in data["spells"].size():
		var child = $Items.get_child(idx)
		var spid = data["spells"][idx]
		var spell = Items.all_spells[spid]
		child.get_child(0).texture = spell.texture
		
	prices = data["prices"]
	soul_cost = data["soul_cost"]
	soul_spell = data["soul_spell"]


func get_item_in_tier(tier:int = 1) -> Item:
	var k :Array = Items.spells[tier].keys()
	var spell = k[Items.LootRNG.randi()%k.size()]
	var tries := 0
	while spell in spells and tries < 100:
		tries += 1
		spell = k[Items.LootRNG.randi()%k.size()]
		if not spell in spells: # This loop doesn't end if I don't do this
			# fuck if i kknow why
			break
	spells.append(spell)
	return Items.spells[tier][spell]


func assign_price(spell_name:String):
	var cost_of_blood := 1.0
	if not Items.player_health.blood_module:
		return 0.0
	match Items.player_health.blood_module.substance:
		"water": cost_of_blood = 1.4
		"nitroglycerine": cost_of_blood = 0.7
	return (0.15 + randf()*0.1)*Items.all_spells[spell_name].tier*cost_of_blood
