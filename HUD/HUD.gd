extends CanvasLayer

onready var UsefulAdvice := $HUD/Generating/UsefulAdvice
onready var LastItem := $HUD/LastItem
onready var HotHUD := $HUD/Hot
onready var ColdHUD := $HUD/Cold
onready var DeathScreen := $HUD/Death
onready var GeneratingScreen := $HUD/Generating
onready var DeathScreenInfo := $HUD/Death/Info
onready var MessageHUD := $HUD/Messages
onready var ScrapsAmount := $HUD/Scraps/Amount
onready var WandHUD := $HUD/Wands
onready var CompanionWandHUD := $HUD/CompanionWands
onready var SpellBagHUD := $HUD/SpellBag
onready var WandSpellHUD := $HUD/Spells
onready var DescriptionBox := $HUD/Description
onready var ShortDescriptionBox := $HUD/ShortDesc
onready var DescriptionBoxName := $HUD/Description/Name
onready var DescriptionBoxInfo := $HUD/Description/Description
onready var MouseSpellSlot := $HUD/MouseSlot
onready var MouseWandSlot := $HUD/MouseWand

var Player :KinematicBody2D
var Map :TileMap

var messages := []
var message_timer := 0.0
var mouse_spell = null
var mouse_wand = null
var generated := false
var block_cast := false
var level_ended := false
var advice := [
	"Avoid breaking your knees by not falling long distances",
	"The best way for your runs to last longer is to reduce the amount of times you're hit",
	"Finish the levels to progress through the game",
	"If you're getting bad items, try having better luck",
	"You need at least one leg to be able to jump, make sure not to break both",
	"Blood is useful! Try and keep as much of it as possible inside your body",
	"In order to stay alive, survive as long as possible",
	"If you get lost, try to remember where you are",
	"If an enemy attacks you, dodge",
	"Use the controls to maneuver your character",
	"If you find yourself surrounded by enemies, get out of there",
	"Nothing beautiful can last",
	"Death is the only thing that ends a run",
	"The best way to stay alive is not dying",
	"In any system optimizing for X, the possibility arises to throw any value under the bus for optimized X",
	"THROW WHAT YOU LOVE MOST INTO THE FIRE AND I CAN GIVE YOU POWER",
	"Stay away from explosions",
	"Try your best to not be set on fire",
	"Try your best to have good luck",
	"Permanence is unachievable",
	"Some items are bad, try to not get them in chests",
	"It says gullible on the ceiling",
	"Take your time, but not enough time for an enemy to shoot you",
	"It is a mystery",
	"Look after your soul. You need that.",
]
var player_died := false
var end_times : String # How long did the run last


# Control the inventory with controller
var which_inventory := 2
var which_slot := 0

var has_healed := false
var has_seen_info := false


func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]
	Map = get_tree().get_nodes_in_group("World")[0]
	if Items.level == 1:
		Items.using_seed = Items.WorldRNG.seed
	UsefulAdvice.text = advice[randi()%advice.size()] + "\n"
	UsefulAdvice.text += "Seed: " + str(Items.using_seed)


func _process(delta):
	# Control the tutorial
	if Items.player_health.poked_holes > 0 and not Config.tutorial["healed"]:
		$HUD/HealTutorial.visible = true
	elif $HUD/HealTutorial.visible and not Config.tutorial["healed"] and Items.player_health.poked_holes == 0 and not has_healed:
		Config.tutorial["healed"] = true
		$HUD/HealTutorial.visible = false
		Config.save_config()
		has_healed = true
	# Control the temperature vignettes
	if Items.player_health.temperature > 30:
		HotHUD.modulate.a = lerp(HotHUD.modulate.a, (Items.player_health.temperature-30)/110.0, 0.2)
	else:
		ColdHUD.modulate.a = lerp(ColdHUD.modulate.a, (Items.player_health.temperature-30)/-60.0, 0.2)
	if generated and not player_died and not level_ended:
		GeneratingScreen.modulate.a = move_toward(GeneratingScreen.modulate.a, 0.0, 0.2)
	
	# If the player is dead, show the death screen
	if player_died:
		DeathScreen.modulate.a = move_toward(DeathScreen.modulate.a, 1.0, 0.2)
		DeathScreenInfo.text = "Run Time: " + end_times + "\n"
		var death := "Internal organs damaged by impact"
		match Player.health_object().cause_of_death:
			Flesh.DEATHS.BLED: death = "Ran out of blood"
			Flesh.DEATHS.HOLES: death = "Sliced to at least two pieces"
			Flesh.DEATHS.HYPER: death = "Extremely high temperatures"
			Flesh.DEATHS.HYPO: death = "Extremely low temperatures"
			Flesh.DEATHS.SOUL: death = "Soul leaked out of her body"
		DeathScreenInfo.text += "Cause Of Death: " + death + "\n"
		DeathScreenInfo.text += "Levels: " + str(Items.level) + "\n"
		DeathScreenInfo.text += "Seed: " + str(Items.using_seed) + "\n\n"
		DeathScreenInfo.text += "Right click to start a new run"
		# If the Generating World screen is visible on screen
		# the player's data is reset and the scene is reloaded
		if GeneratingScreen.modulate.a > 0.9:
			Items.reset_player()
			get_tree().change_scene("res://Game.tscn")
		
		# If the player right clicks, generate a new world
		if Input.is_action_just_released("Interact2"):
			Items.player_health = Flesh.new()
			GeneratingScreen.modulate.a = 1.0
	
	# If the player didn't die, and instead the level ended
	elif level_ended:
		# If the generating world screen is fully visible,
		# reload the scene without resetting the player's progress
		if GeneratingScreen.modulate.a > 0.9:
			get_tree().change_scene("res://Game.tscn")
			
		# Generating World screen fadein
		GeneratingScreen.modulate.a = move_toward(GeneratingScreen.modulate.a, 1.0, 0.2)
		
		# The fadein must go after the check to make sure it's fully faded in
		# when the scene change begins
	
	# If there are messages to read, show them
	MessageHUD.bbcode_text = ""
	MessageHUD.margin_top = lerp(MessageHUD.margin_top, 19, 0.2)
	if not messages.empty():
		MessageHUD.modulate.a = lerp(MessageHUD.modulate.a, 1.0, 0.2)
		message_timer += delta
		for i in min(messages.size(), 3):
			if i != 0:
				MessageHUD.bbcode_text += "\n"
			MessageHUD.bbcode_text += "[center]" + messages[i] + "[/center]"
		if message_timer > messages[0].length()*0.2:
			message_timer = 0.0
			messages.pop_front()
	else:
		MessageHUD.modulate.a = lerp(MessageHUD.modulate.a, 0.0, 0.2)
	
	# Inventory and items in HUD
	# Control the thing that displays the last picked up item
	if Items.last_pickup == null:
		LastItem.texture = null
	else:
		LastItem.texture = Items.last_pickup.texture
	
	# Shows the amount of clothes scraps the player has
	ScrapsAmount.text = str(Items.cloth_scraps)
	
	# Show the wands the player is carrying
	for i in 6:
		if i < Items.player_wands.size():
			WandHUD.get_child(i).render_wand(Items.player_wands[i], i == Items.selected_wand)
		else: 
			WandHUD.get_child(i).render_wand(null, false)
	for i in CompanionWandHUD.get_child_count():
		if Items.companions.size() > i:
			CompanionWandHUD.get_child(i).render_wand(Items.companions[i][1])
			CompanionWandHUD.get_child(i).visible = true
		else:
			CompanionWandHUD.get_child(i).visible = false
			
	
	# Show the spells the player is carrying
	for i in SpellBagHUD.get_child_count():
		if i < Items.player_spells.size():
			SpellBagHUD.get_child(i).texture = Items.player_spells[i].texture
		else:
			SpellBagHUD.get_child(i).texture = preload("res://Sprites/Spells/Empty.png")
	
	# Show the spells the wand the player is using has
	for i in WandSpellHUD.get_child_count():
		# If a non-empty wand slot is selected
		if Items.get_player_wand() != null:
			# Make the spell hud visible
			WandSpellHUD.visible = true
			var wand :Wand = Items.get_player_wand()
			# If the wand has this slot
			if i < wand.spell_capacity:
				# Make it visible
				WandSpellHUD.get_child(i).visible = true
				# If the isn't empty, show the spell's texture
				if i < wand.spells.size():
					WandSpellHUD.get_child(i).texture = wand.spells[i].texture
				else: # if it is empty, show the empty slot texture
					WandSpellHUD.get_child(i).texture = preload("res://Sprites/Spells/Empty.png")
			else: # If the wand doesn't have this slot
				WandSpellHUD.get_child(i).visible = false
		else: # If an empty wand slot is selected
			WandSpellHUD.visible = false
	
	var mouse := get_viewport().get_mouse_position()
	
	# Reset the description boxes' visibility
	DescriptionBox.visible = false
	ShortDescriptionBox.visible = false
	# Variables for which inventory the player click and what slot
	var clicked := -1
	var slot := -1
	block_cast = false # Also stop blocking the player's ability to
	# cast spells
	
	# Navigate inventory with keyboard
	# If the mouse is in the wands' area
	if mouse.x < 116 and mouse.y > 4 and mouse.y < 20:
		block_cast = true 
		for i in 6:
			# If a slot is selected
			if mouse.x >= 4+i*(16+4) and mouse.x < 4+(i+1)*(16+4):
				# Set the inventory and slot clicked, and don't let the
				# player cast spells
				clicked = 2
				slot = i
				# If the slot isn't empty
				if i < Items.player_wands.size():
					var d_wand :Wand = Items.player_wands[i]
					# Which information to set
					if Input.is_action_pressed("see_info"):
						DescriptionBox.visible = true
						var new_text := "[img]res://Sprites/Menus/WandIcon.png[/img] [color=#ffbd00]Wand[/color]"
						if new_text != DescriptionBoxName.bbcode_text:
							DescriptionBoxName.bbcode_text = new_text
						new_text = "[img]res://Sprites/Menus/CastDelayIcon.png[/img] Cast Cooldown: " + str(d_wand.cast_cooldown).pad_decimals(3) + "s"
						new_text += "\n[img]res://Sprites/Menus/CooldownIcon.png[/img] Recharge Time: " + str(d_wand.recharge_cooldown).pad_decimals(3) + "s"
						new_text += "\nTemp. Resistance: " + str(1.0/d_wand.heat_resistance).pad_decimals(2)
						new_text += "\nSoul Resistance: " + str(1.0/d_wand.soul_resistance).pad_decimals(2)
						new_text += "\nPush Resistance: " + str(1.0/d_wand.push_resistance).pad_decimals(2)
						if d_wand.shuffle:
							new_text += "\nShuffle"
						if DescriptionBoxInfo.bbcode_text != new_text:
							DescriptionBoxInfo.bbcode_text = new_text
					else:
						ShortDescriptionBox.visible = true
						ShortDescriptionBox.bbcode_text = "[img]res://Sprites/Menus/CastDelayIcon.png[/img] " + str(d_wand.cast_cooldown).pad_decimals(2) + "s [img]res://Sprites/Menus/CooldownIcon.png[/img] " + str(d_wand.recharge_cooldown).pad_decimals(2) + "s"
				break # Stop checking for if it's in a slot, we already did all this stuff
	
	# If the mouse is in the companions' wand area
	# DEPRECATED
	elif mouse.x > 140 and mouse.y > 4 and mouse.y < 20 and mouse.x < 140 + 20*Items.companions.size():
		block_cast = true 
		for i in Items.companions.size():
			# If a slot is selected
			if mouse.x >= 140+i*(16+4) and mouse.x < 140+(i+1)*(16+4):
				# Set the inventory and slot clicked, and don't let the
				# player cast spells
				clicked = 3
				slot = i
				# If the slot isn't empty
				if Items.companions[i][1] != null:
					# Which information to set
					if Input.is_action_pressed("see_info"):
						DescriptionBox.visible = true
						DescriptionBoxName.bbcode_text = "[color=#ffbd00]Wand[/color]"
						DescriptionBoxInfo.bbcode_text = "Spell Cooldown: " + str(Items.companions[i][1].cast_cooldown).pad_decimals(3)
						DescriptionBoxInfo.bbcode_text += "\nUsage Cooldown: " + str(Items.companions[i][1].recharge_cooldown).pad_decimals(3)
						if Items.companions[i][1].shuffle:
							DescriptionBoxInfo.bbcode_text += "\nShuffle"
					else:
						ShortDescriptionBox.visible = true
						ShortDescriptionBox.bbcode_text =  str(Items.companions[i][1].cast_cooldown).pad_decimals(2) + "/" + str(Items.companions[i][1].recharge_cooldown).pad_decimals(2)
				break # Stop checking for if it's in a slot, we already did all this stuff
	
	# If the mouse is in the wands' spells area and is holding a wand
	elif mouse.x < 240 and mouse.y > 25 and mouse.y < 25+16 and Items.get_player_wand() != null:
		var wand :Wand = Items.get_player_wand()
		for i in Wand.MAX_CAPACITY:
			# If it's in a slot
			if mouse.x >= 4+i*(16+4) and mouse.x < (i+1)*(16+4):
				# If this slot is had by the wand
				if i < wand.spell_capacity:
					# Don't let the player cast spells
					block_cast = true
					clicked = 1
					# Then this is the slot that was clicked (aka I didn't click an empty area)
					slot = i
					# Set the description accordingly
					if i < wand.spells.size():
						if Input.is_action_pressed("see_info"):
							DescriptionBox.visible = true
							DescriptionBoxName.bbcode_text = "[color=#ffbd00]" + wand.spells[i].name + "[/color]"
							DescriptionBoxInfo.bbcode_text = wand.spells[i].description
						else:
							ShortDescriptionBox.visible = true
							ShortDescriptionBox.text =  wand.spells[i].name
	
	# If the mouse is in the spells bag's area and is holding a wand
	elif mouse.x < 16 + 4 and mouse.y > 62 and mouse.y < 178 and mouse.x > 4:
		block_cast = true
		for i in 6:
			# If it's in a slot
			if mouse.y >= 62+i*(16+4) and mouse.y < 62+(i+1)*(16+4):
				# Set what inventory and slot was clicked, block spell casts
				clicked = 0
				slot = i
				# Descriptions
				if i < Items.player_spells.size():
					if Input.is_action_pressed("see_info"):
						DescriptionBox.visible = true
						DescriptionBoxName.bbcode_text = "[color=#ffbd00]" + Items.player_spells[i].name + "[/color]"
						DescriptionBoxInfo.bbcode_text = Items.player_spells[i].description
					else:
						ShortDescriptionBox.visible = true
						ShortDescriptionBox.text =  Items.player_spells[i].name
	
	# If the player is hovering over the last picked_up item, handle descriptions
	elif Items.last_pickup != null and mouse.x > 4 and mouse.y > 184 and mouse.x < 20 and mouse.y < 200:
		if Input.is_action_pressed("see_info"):
			DescriptionBox.visible = true
			DescriptionBoxName.bbcode_text = "[color=#ffbd00]" + Items.last_pickup.name + "[/color]"
			DescriptionBoxInfo.bbcode_text = Items.last_pickup.description
		else:
			ShortDescriptionBox.visible = true
			ShortDescriptionBox.bbcode_text = Items.last_pickup.name
	
	# Navigate inventory with controller
	if Config.last_input_was_controller:
		match which_inventory:
			2:
				if Input.is_action_just_released("scrollup"):
					Items.selected_wand -= 1
					if Items.selected_wand < 0:
						Items.selected_wand = 5
				elif Input.is_action_just_released("scrolldown"):
					Items.selected_wand = Items.selected_wand + 1
					if Items.selected_wand >= 6:
						Items.selected_wand = 5
						if Items.companions.size() > 0:
							which_inventory = 3
						else:
							Items.selected_wand = 0
				elif Input.is_action_just_pressed("scroll_left"):
					which_inventory = 0
					which_slot = 5
				elif Input.is_action_just_pressed("scroll_right"):
					if Items.get_player_wand() != null:
						which_inventory = 1
					else:
						which_inventory = 0
					which_slot = 0
				$HUD/ControllerSelect.rect_position = Vector2(-20,20)
			0:
				if Input.is_action_just_released("scrollup"):
					which_slot -= 1
					if which_slot < 0:
						which_slot = 0
						if Items.get_player_wand() != null:
							which_inventory = 1
				elif Input.is_action_just_released("scrolldown"):
					which_slot = which_slot + 1
					if which_slot >= 6:
						which_slot = 0
						which_inventory = 2
				elif Input.is_action_just_pressed("scroll_left"):
					which_inventory = 2
				elif Input.is_action_just_pressed("scroll_right"):
					if Items.get_player_wand() != null:
						which_inventory = 1
				$HUD/ControllerSelect.rect_position = Vector2(4+16+8,62+3+20*which_slot)
			1:
				if Input.is_action_just_released("scrollup"):
					which_slot -= 1
					if which_slot < 0:
						which_slot = Items.get_player_wand().spell_capacity - 1
				elif Input.is_action_just_released("scrolldown"):
					which_slot = which_slot + 1
					if which_slot >= Items.get_player_wand().spell_capacity:
						which_slot = 0
				elif Input.is_action_just_pressed("scroll_left"):
					which_inventory = 2
				elif Input.is_action_just_pressed("scroll_right"):
					which_inventory = 0
				$HUD/ControllerSelect.rect_position = Vector2(4+3+20*which_slot, 20+16+8)
			3:
				if Input.is_action_just_released("scrollup"):
					which_slot -= 1
					if which_slot < 0:
						Items.selected_wand = 5
						which_inventory = 2
				elif Input.is_action_just_released("scrolldown"):
					which_slot = which_slot + 1
					if which_slot >= 6:
						which_slot = 0
				$HUD/ControllerSelect.rect_position = Vector2(140+8+20*which_slot, 4+16+3)
		
				
	# If the player clicks a part of the inventory, swap that slot's content
	# with the mouse slot's content
	if not Config.last_input_was_controller and Input.is_action_just_pressed("Interact1") and clicked != -1:
		var clicked_array: Array
		var clicked_array_max: int = 6
		var clicked_array_type: String = ""
		var doswap := true
		match clicked:
			1:
				if slot != -1:
					doswap = false
					
					if Items.get_player_wand() != null:
						clicked_array = Items.get_player_wand().spells
						clicked_array_max = Items.get_player_wand().spell_capacity
						clicked_array_type = "spell"
						
						print(clicked_array.size(), slot)
						if clicked_array.size() == clicked_array_max or mouse_spell == null or clicked_array.size() <= slot or Input.is_key_pressed(KEY_SHIFT):
							doswap = true
						else:
							var new_array = []
							for i in clicked_array.size() + 1:
								if i < slot + 1:
									new_array.append(clicked_array[i])
								elif i == slot + 1:
									new_array.append(mouse_spell)
								else:
									new_array.append(clicked_array[i-1])
							Items.get_player_wand().spells = new_array
							mouse_spell = null
			0:
				if slot != -1:
					clicked_array = Items.player_spells
					clicked_array_type = "spell"
					
			2:
				if slot != -1:
					clicked_array = Items.player_wands
					clicked_array_type = "wand"
					if slot <= Items.selected_wand:
						Items.selected_wand -= 1
					if slot < 0:
						Items.selected_wand = 0
			3:
				if slot != -1:
					clicked_array = Items.companions[slot][1]
					clicked_array_type = "wand"
		
		
		if doswap:
			if slot < clicked_array.size():
				var k = clicked_array[slot]
				
				if k is Spell:
					clicked_array[slot] = mouse_spell
					mouse_spell = k
				elif k is Wand:
					clicked_array[slot] = mouse_wand
					mouse_wand = k
				
			elif slot <= clicked_array_max and clicked_array_type == "spell":
				clicked_array.append(mouse_spell)
				mouse_spell = null
			elif slot <= clicked_array_max and clicked_array_type == "wand":
				clicked_array.append(mouse_wand)
				mouse_wand = null
		
		while clicked_array.find(null) != -1:
			clicked_array.remove(clicked_array.find(null))
			
	elif Config.last_input_was_controller and  Input.is_action_just_pressed("select_inventory"):
		match which_inventory:
			0:
				var k :Spell = Items.player_spells[which_slot]
				Items.player_spells[which_slot] = mouse_spell
				mouse_spell = k
			1:
				if Items.get_player_wand() != null:
					var wand :Wand = Items.get_player_wand()
					var k :Spell = wand.spells[which_slot]
					wand.spells[which_slot] = mouse_spell
					mouse_spell = k
			2:
				var k :Wand = Items.get_player_wand()
				Items.player_wands[Items.selected_wand] = mouse_wand
				mouse_wand = k
			3:
				var k :Wand = Items.companions[which_slot][1]
				Items.companions[which_slot][1] = mouse_wand
				mouse_wand = k
				
	
	
	
	# If the player right clicks and is not in an inventory space
	# drop the  item
	if (Input.is_action_just_pressed("Interact2") and clicked == -1) or (Input.is_action_just_pressed("Interact2") and Config.last_input_was_controller):
		if mouse_spell != null:
			Map.summon_spell(mouse_spell, Player.position, Vector2(-120 + randf()*240, -100))
		mouse_spell = null
		if mouse_wand != null:
			Map.summon_wand(mouse_wand, Player.position, Vector2(-120 + randf()*240, -100))
		mouse_wand = null
	
	# Hide the mouse slots if they have nothing
	MouseSpellSlot.visible = mouse_spell != null
	MouseWandSlot.visible = mouse_wand != null
	if mouse_spell != null:
		MouseSpellSlot.texture = mouse_spell.texture
	if mouse_wand != null:
		MouseWandSlot.render_wand(mouse_wand, true)
	# Position them
	MouseSpellSlot.rect_position = mouse + Vector2(-16,0)
	MouseWandSlot.rect_position = mouse + Vector2(0,-16)
	
	# Set the size of the description box
	DescriptionBox.rect_size = Vector2(144, 18+DescriptionBoxInfo.rect_size.y+4)
	ShortDescriptionBox.rect_size.y = 0
	
	# Move the description box up if it's offscreen
	if mouse.y + DescriptionBox.rect_size.y > 225:
		DescriptionBox.rect_position = mouse - Vector2(0, DescriptionBox.rect_size.y)
	else:
		DescriptionBox.rect_position = mouse
	ShortDescriptionBox.rect_position = mouse
	$HUD/ShiftButton.rect_position = ShortDescriptionBox.rect_position + ShortDescriptionBox.rect_size - Vector2(19, 4)
	$HUD/ShiftButton.visible = ShortDescriptionBox.visible
	


func add_message(message:String):
	messages.append(message)


func _on_generated_world():
	generated = true


# Calculate time in minutes and seconds
func _on_player_died():
	var msecs :int = OS.get_ticks_msec() - Items.run_start_time
	var secs = float(msecs) / 1000.0
	var isecs = int(secs) 
	var csecs =  isecs % 60
	var cmsecs = secs - isecs
	var mins = (isecs / 60) % 60
	var hours = (isecs / 60 / 60)
	end_times = str(hours).pad_zeros(2) + "h" + str(mins).pad_zeros(2) + "m" + str(csecs).pad_zeros(2) + "s"
	player_died = true
	$HUD/DeathSFX.play()

func _on_level_ended():
	level_ended = true
	Items.level += 1

