extends Node2D


var spells := []
var prices := []
var Player :Character

var soul_spell := false
var soul_cost := 0.1
var max_soul := 1.0

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
			soul_spell = Items.count_player_items("DE4L") and Items.LootRNG.randf() < 0.01 * Items.count_player_items("DE4L")
			soul_cost = Items.player_health.soul * 0.9
			max_soul = max(Items.player_health.soul, Items.player_health.needed_soul)
			if soul_spell:
				var a := spells.size()-1
				spells.remove(a)
				var spr := $Items.get_child(a).get_child(0)
				spr.texture = get_item_in_tier(Items.LootRNG.randi()%2 + 3).texture
				spr.position = Vector2(-8, -16)
		$SoulParticles.emitting = soul_spell
		max_soul = max(Items.player_health.soul, max_soul)
		var selected := -1
		var j := 0
		for i in $Sacrifice.get_overlapping_bodies():
			if i.get("spell"):
				if not i.spell is SpellMod:
					if i.is_in_group("SpellItemEntity"):
						Items.player_health.blood = clamp(Items.player_health.blood + assign_price(i.spell.id) * 0.7, 0.0, Items.player_health.max_blood)
						i.queue_free()
		for i in $Items.get_children():
			var mult := 6.0
			if Player.position.distance_to(i.position + position) < 30.0:
				mult = 12.0
				selected = j
			i.rotation = lerp_angle(i.rotation, sin(time*mult+j*0.1)*0.3, 0.1)
			j += 1
		
		if selected == $Items.get_child_count() - 1 and soul_spell:
			$BloodBar.modulate = Color("#b9ffad")
			$BloodBar/CostBar.modulate = Color("#25ca0d")
			$BloodBar/BloodBar.max_value = max_soul
			$BloodBar/BloodBar.value = Items.player_health.soul
			$BloodBar/CostBar.value = Items.player_health.soul - soul_cost
			$BloodBar/BloodBar/Label.text = "S0UL"
		else:
			$BloodBar.modulate = Color("#ffadad")
			$BloodBar/CostBar.modulate = Color("#960000")
			$BloodBar/BloodBar/Label.text = "BLOOD"
			$BloodBar/BloodBar.max_value = Items.player_health.max_blood
			$BloodBar/BloodBar.value = Items.player_health.blood
			$BloodBar/CostBar.value = Items.player_health.blood - prices[selected]
		
		if selected != -1:
			$BloodBar/CostBar.visible = true
			
			if selected == $Items.get_child_count() - 1 and soul_spell:
				if Input.is_action_just_pressed("down") and $Items.get_child(selected).visible and null in Items.player_spells and Items.player_health.soul - soul_cost > 0.0:
					$Items.get_child(selected).visible = false
					Items.player_spells[Items.player_spells.find(null)] = Items.all_spells[spells[selected]]
					Items.player_health.soul -= soul_cost
			else:
				if Input.is_action_just_pressed("down") and $Items.get_child(selected).visible and null in Items.player_spells and Items.player_health.blood - prices[selected] > 0.0:
					$Items.get_child(selected).visible = false
					Items.player_spells[Items.player_spells.find(null)] = Items.all_spells[spells[selected]]
					Items.player_health.blood -= prices[selected]
		else:
			$BloodBar/CostBar.visible = false
		
		
		$BloodBar/CostBar.max_value = $BloodBar/BloodBar.max_value
	else:
		$SoulParticles.emitting = false

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
	return (0.1 + randf()*0.1)*Items.all_spells[spell_name].tier*cost_of_blood
