extends Node2D


var spells := []
var prices := []
var Player :Character

var time := 0.0

func _ready() -> void:
	Player = get_tree().get_nodes_in_group("Player")[0]
	for i in $Items.get_child_count():
		var spr := Sprite.new()
		$Items.get_child(i).add_child(spr)
		spr.texture = get_item_in_tier(Items.LootRNG.randi()%3 + 1).texture
		spr.position = Vector2(-8, -16)


func _process(delta: float) -> void:
	time += delta
	if Rect2(position, Vector2(66, 33) * 8).has_point(Player.position):
		if prices.empty():
			for i in spells.size():
				prices.append(assign_price(spells[i]))
		$BloodBar/BloodBar.max_value = Items.player_health.max_blood
		$BloodBar/BloodBar.value = Items.player_health.blood
		$BloodBar/CostBar.max_value = Items.player_health.max_blood
		$BloodBar/CostBar.visible = false
		var selected := -1
		var j := 0
		for i in $Sacrifice.get_overlapping_bodies():
			if not i.spell is SpellMod:
				if i.is_in_group("SpellItemEntity"):
					assign_price(i.spell.name_id)
					i.queue_free()
		for i in $Items.get_children():
			var mult := 6.0
			if Player.position.distance_to(i.position + position) < 30.0:
				mult = 12.0
				$BloodBar/CostBar.value = Items.player_health.blood - prices[j]
				$BloodBar/CostBar.visible = true
				selected = j
			i.rotation = lerp_angle(i.rotation, sin(time*mult+j*0.1)*0.3, 0.1)
			j += 1
		if selected != -1:
			if Input.is_action_just_pressed("down") and $Items.get_child(selected).visible and null in Items.player_spells and Items.player_health.blood - prices[selected] > 0.0:
				$Items.get_child(selected).visible = false
				Items.player_spells[Items.player_spells.find(null)] = Items.all_spells[spells[selected]]
				Items.player_health.blood -= prices[selected]


func get_item_in_tier(tier:int = 1) -> Item:
	var k :Array = Items.spells[tier].keys()
	var spell = k[Items.LootRNG.randi()%k.size()]
	while spell in spells:
		spell = k[Items.LootRNG.randi()%k.size()]
		if not spell in spells: # This loop doesn't end if I don't do this
			# fuck if i kknow why
			break
	spells.append(spell)
	return Items.spells[tier][spell]


func assign_price(spell_name:String):
	var cost_of_blood := 1.0
	match Items.player_health.blood_substance:
		"water": cost_of_blood = 1.4
		"nitroglycerine": cost_of_blood = 0.7
	return (0.08 + randf()*0.04)*Items.all_spells[spell_name].tier*cost_of_blood
